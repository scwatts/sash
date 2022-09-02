include { PREPARE_HMF_HOTSPOTS } from '../../modules/local/smlv_somatic/annotate/prepare_hmf_hotspots/main'
include { PREPARE_ANNOTATION_TOML } from '../../modules/local/smlv_somatic/annotate/prepare_annotation_toml/main'
include { VCFANNO } from '../../modules/local/smlv_somatic/annotate/vcfanno/main'
include { SUBSET } from '../../modules/local/smlv_somatic/annotate/subset/main'
include { CLEAN_ANNOTATIONS } from '../../modules/local/smlv_somatic/annotate/clean_annotations/main'
include { PREPARE_PCGR_VCF } from '../../modules/local/smlv_somatic/annotate/prepare_pcgr_vcf/main'
include { ANNOTATE_SAGE_PON } from '../../modules/local/smlv_somatic/annotate/annotate_sage_pon/main'
include { ANNOTATE_UMCCR_PON } from '../../modules/local/smlv_somatic/annotate/annotate_umccr_pon/main'
include { PCGR } from '../../modules/local/smlv_somatic/annotate/pcgr/main'
include { PROCESS_PCGR_ANNOTATIONS } from '../../modules/local/smlv_somatic/annotate/process_pcgr_annotations/main'
include { FILTER_VEP_CSQ } from '../../modules/local/smlv_somatic/annotate/filter_vep_csq/main'


workflow SMLV_SOMATIC_ANNOTATE {
  take:
    meta
    vcf
    tbi
    params

  main:
    // Channel for version.yml files
    ch_versions = Channel.empty()

    PREPARE_HMF_HOTSPOTS(
      params.refdata.hotspots_vcf,
    )

    PREPARE_ANNOTATION_TOML(
      PREPARE_HMF_HOTSPOTS.out.vcf,
      params.refdata.ga4gh_dir,
      params.refdata.lcr,
      params.refdata.segdup,
      params.refdata.gnomad_vcf,
      params.refdata.giab_high_conf,
      params.refdata.encode,
    )

    // NOTE(SW): all indices must be staged into work directory
    refdata_lcr_tbi = "${params.refdata.lcr}.tbi"
    refdata_segdup_tbi = "${params.refdata.segdup}.tbi"
    refdata_gnomad_vcf_tbi = "${params.refdata.gnomad_vcf}.tbi"
    refdata_giab_high_conf_tbi = "${params.refdata.giab_high_conf}.tbi"
    refdata_encode_tbi = "${params.refdata.encode}.tbi"
    VCFANNO(
      vcf,
      PREPARE_ANNOTATION_TOML.out.toml,
      PREPARE_HMF_HOTSPOTS.out.vcf,
      params.refdata.ga4gh_dir,
      params.refdata.lcr,
      params.refdata.segdup,
      params.refdata.gnomad_vcf,
      params.refdata.giab_high_conf,
      params.refdata.encode,
      PREPARE_HMF_HOTSPOTS.out.tbi,
      refdata_lcr_tbi,
      refdata_segdup_tbi,
      refdata_gnomad_vcf_tbi,
      refdata_giab_high_conf_tbi,
      refdata_encode_tbi,
    )

    SUBSET(
      meta,
      VCFANNO.out.vcf,
      VCFANNO.out.tbi,
    )

    CLEAN_ANNOTATIONS(
      meta,
      SUBSET.out.vcf,
      SUBSET.out.tbi,
    )

    PREPARE_PCGR_VCF(
      meta,
      CLEAN_ANNOTATIONS.out.vcf,
    )

    refdata_sage_pon_tbi = "${params.refdata.sage_pon}.tbi"
    ANNOTATE_SAGE_PON(
      meta,
      PREPARE_PCGR_VCF.out.vcf,
      PREPARE_PCGR_VCF.out.tbi,
      params.refdata.sage_pon,
      refdata_sage_pon_tbi,
    )

    ANNOTATE_UMCCR_PON(
      meta,
      ANNOTATE_SAGE_PON.out.vcf,
      ANNOTATE_SAGE_PON.out.tbi,
      params.refdata.umccr_pon_dir,
      params.refdata.umccr_pon_snps_toml,
      params.refdata.umccr_pon_indels_toml,
    )

    PCGR(
      meta,
      ANNOTATE_UMCCR_PON.out.vcf,
      ANNOTATE_UMCCR_PON.out.tbi,
      params.refdata.pcgr_dir,
      params.refdata.pcgr_toml,
      params.refdata.cpsr_toml,
    )

    PROCESS_PCGR_ANNOTATIONS(
      meta,
      ANNOTATE_UMCCR_PON.out.vcf,
      PCGR.out.tsv,
      PCGR.out.vcf,
      PCGR.out.tbi,
    )

    FILTER_VEP_CSQ(
      meta,
      PROCESS_PCGR_ANNOTATIONS.out.vcf,
      PROCESS_PCGR_ANNOTATIONS.out.tbi,
    )

  emit:
    vcf = FILTER_VEP_CSQ.out.vcf
    subset_stats = SUBSET.out.stats

    versions = ch_versions // channel: [versions.yml]
}
