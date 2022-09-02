include { AMBER } from '../../modules/local/cnv/amber/main'
include { COBALT } from '../../modules/local/cnv/cobalt/main'
include { PREPARE_SMLV_VCF } from '../../modules/local/cnv/prepare_smlv_vcf/main'
include { PURPLE } from '../../modules/local/cnv/purple/main'
include { GENERATE_BAF_PLOT } from '../../modules/local/cnv/generate_baf_plot/main'


workflow CNV {
  take:
    meta
    sv_filtered_vcf
    smlv_somatic_vcf
    params

  main:
    // Channel for version.yml files
    ch_versions = Channel.empty()

    AMBER(
      meta,
      params.input.tumor_bam,
      params.input.normal_bam,
      params.refdata.genome_name,
      params.refdata.genome_dir,
      params.refdata.amber_germline_het_pon,
    )

    COBALT(
      meta,
      params.input.tumor_bam,
      params.input.normal_bam,
      params.refdata.genome_name,
      params.refdata.genome_dir,
      params.refdata.hmf_gc_profile,
    )

    PREPARE_SMLV_VCF(
      meta,
      smlv_somatic_vcf,
    )

    PURPLE(
      meta,
      sv_filtered_vcf,
      PREPARE_SMLV_VCF.out.vcf,
      AMBER.out.amber_dir,
      COBALT.out.cobalt_dir,
      params.refdata.genome_name,
      params.refdata.genome_dir,
      params.refdata.hmf_gc_profile,
    )

    GENERATE_BAF_PLOT(
      meta,
      PURPLE.out.purple_dir,
      params.refdata.circos_baf_conf,
      params.refdata.circos_gaps,
    )

  emit:
    purple_sv_vcf = PURPLE.out.sv_vcf
    purple_cnv_tsv = PURPLE.out.cnv_tsv

    versions = ch_versions // channel: [versions.yml]
}
