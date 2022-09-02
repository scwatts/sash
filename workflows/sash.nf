include { PIERIAN } from '../modules/local/misc/pierian/main'


include { SMLV_SOMATIC } from '../subworkflows/local/smlv_somatic'
include { SV } from '../subworkflows/local/sv'


workflow SASH {
  // Channel for version.yml files
  ch_versions = Channel.empty()

  meta = [
    id: params.meta.subject,
    tumor_name: params.meta.tumor_name,
    normal_name: params.meta.normal_name,
  ]

  SMLV_SOMATIC(
    meta,
    params,
  )

  SV(
    meta,
    SMLV_SOMATIC.out.vcf,
    params,
  )

  //PIERIAN(
  //  meta,
  //  SMLV_SOMATIC.out.vcf,
  //  SV.out.purple_cnv_tsv,
  //)
}
