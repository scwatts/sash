include { FILTER_PASS_AND_SORT } from '../../modules/local/smlv_somatic/filter_pass_and_sort/main'
include { FILTER_ALT } from '../../modules/local/smlv_somatic/filter_alt/main'
include { FILTER_ANNOTATIONS } from '../../modules/local/smlv_somatic/filter_annotations/main'
include { FILTER_APPLY } from '../../modules/local/smlv_somatic/filter_apply/main'
include { BCFTOOLS_STATS } from '../../modules/local/smlv_somatic/bcftools_stats/main'
include { GENERATE_STATS } from '../../modules/local/smlv_somatic/generate_stats/main'
include { GENERATE_MAF } from '../../modules/local/smlv_somatic/generate_maf/main'


include { SAGE } from './sage'
include { SMLV_SOMATIC_ANNOTATE as ANNOTATE } from './smlv_somatic_annotate'


workflow SMLV_SOMATIC {
  take:
    meta
    params

  main:
    // Channel for version.yml files
    ch_versions = Channel.empty()

    FILTER_PASS_AND_SORT(
      meta,
      params.input.tumor_smlv_vcf,
    )

    FILTER_ALT(
      meta,
      FILTER_PASS_AND_SORT.out.vcf,
      FILTER_PASS_AND_SORT.out.tbi,
      params.refdata.main_contigs_bed,
    )

    SAGE(
      meta,
      FILTER_ALT.out.vcf,
      FILTER_ALT.out.tbi,
      params,
    )

    ANNOTATE(
      meta,
      SAGE.out.vcf,
      SAGE.out.tbi,
      params,
    )

    FILTER_ANNOTATIONS(
      meta,
      ANNOTATE.out.vcf,
    )

    FILTER_APPLY(
      meta,
      FILTER_ANNOTATIONS.out.vcf,
    )

    BCFTOOLS_STATS(
      meta,
      FILTER_APPLY.out.vcf,
    )

    GENERATE_STATS(
      meta,
      FILTER_APPLY.out.vcf,
      FILTER_ALT.out.vcf,
      ANNOTATE.out.subset_stats,
    )

    GENERATE_MAF(
      meta,
      FILTER_APPLY.out.vcf,
      params.refdata.genome_name,
      params.refdata.genome_dir,
    )

    //ch_versions = ch_versions.mix(XXX.out.versions)

  emit:
    vcf = FILTER_APPLY.out.vcf
    versions = ch_versions // channel: [versions.yml]
}
