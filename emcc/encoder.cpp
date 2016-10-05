#define PLATFORM_NACL

#include <stddef.h> // For NULL, size_t
#include <cstring> // for malloc etc
#include <stdio.h>

#include "crnlib.h"
#include "dds_defs.h"

const int cDefaultCRNQualityLevel = 128;

extern "C" {
  void crn_compress(void *src, unsigned int src_size, void *dst, unsigned int dst_size);
}

void crn_compress(void *src, unsigned int src_size, void *dst, unsigned int dst_size) {
  float bitrate = 0.0f;
  int quality_level = -1;
  bool srgb_colorspace = true;
  bool create_mipmaps = false;
  bool output_crn = true;
  crn_format fmt = cCRNFmtInvalid;
  bool use_adaptive_block_sizes = true;
  bool set_alpha_to_luma = false;
  bool convert_to_luma = false;
  bool enable_dxt1a = false;
  bool has_alpha_channel = true;

  crn_uint32 *pSrc_image = (crn_uint32*)src;

  crn_comp_params comp_params;
  // comp_params.m_width = width;
  // comp_params.m_height = height;
  comp_params.m_width = 512;
  comp_params.m_height = 512;
  comp_params.set_flag(cCRNCompFlagPerceptual, srgb_colorspace);
  comp_params.set_flag(cCRNCompFlagDXT1AForTransparency, enable_dxt1a && has_alpha_channel);
  comp_params.set_flag(cCRNCompFlagHierarchical, use_adaptive_block_sizes);
  comp_params.m_file_type = output_crn ? cCRNFileTypeCRN : cCRNFileTypeDDS;
  comp_params.m_format = (fmt != cCRNFmtInvalid) ? fmt : (has_alpha_channel ? cCRNFmtDXT5 : cCRNFmtDXT1);
  comp_params.m_pImages[0][0] = pSrc_image;
  comp_params.m_num_helper_threads = 1;

  if (bitrate > 0.0f)
     comp_params.m_target_bitrate = bitrate;
  else if (quality_level >= 0)
     comp_params.m_quality_level = quality_level;
  else if (output_crn)
  {
     // Set a default quality level for CRN, otherwise we'll get the default (highest quality) which leads to huge compressed palettes.
     comp_params.m_quality_level = cDefaultCRNQualityLevel;
  }

  crn_uint32 actual_quality_level;
  float actual_bitrate;
  crn_uint32 output_file_size;

  crn_mipmap_params mip_params;
  mip_params.m_gamma_filtering = srgb_colorspace;
  mip_params.m_mode = create_mipmaps ? cCRNMipModeGenerateMips : cCRNMipModeNoMips;

  void *pOutput_file_data = crn_compress(comp_params, mip_params, output_file_size, &actual_quality_level, &actual_bitrate);

  printf("Compressing to %s\n", crn_get_format_string(comp_params.m_format));
  printf("Compressed to %u bytes, quality level: %u, effective bitrate: %f\n", output_file_size, actual_quality_level, actual_bitrate);

  crn_free_block(pOutput_file_data);
}
