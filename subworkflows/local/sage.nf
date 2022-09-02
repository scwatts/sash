include { ANNOTATE } from '../../modules/local/smlv_somatic/sage/annotate/main'
include { CONCAT_NEW } from '../../modules/local/smlv_somatic/sage/concat_new/main'
include { FILTER_PASS } from '../../modules/local/smlv_somatic/sage/filter_pass/main'
include { FILTER_PRIOR } from '../../modules/local/smlv_somatic/sage/filter_prior/main'
include { RENAME_ANNOTATION } from '../../modules/local/smlv_somatic/sage/rename_annotation/main'
include { REORDER_SAMPLES } from '../../modules/local/smlv_somatic/sage/reorder_samples/main'
include { SAGE as RUN_SAGE } from '../../modules/local/smlv_somatic/sage/sage/main'
include { SORT } from '../../modules/local/smlv_somatic/sage/sort/main'


workflow SAGE {
  take:
    meta
    vcf
    tbi
    params

  main:
    // Channel for version.yml files
    ch_versions = Channel.empty()

    RUN_SAGE(
      meta,
      vcf,
      tbi,
      params.input.tumor_bam,
      params.input.normal_bam,
      params.refdata.genome_name,
      params.refdata.genome_dir,
      params.refdata.hotspots_vcf,
      params.refdata.coding_regions,
    )

    RENAME_ANNOTATION(
      meta,
      RUN_SAGE.out.vcf,
      RUN_SAGE.out.tbi,
    )

    REORDER_SAMPLES(
      meta,
      vcf,
      RENAME_ANNOTATION.out.vcf,
      RENAME_ANNOTATION.out.tbi,
    )

    FILTER_PASS(
      meta,
      REORDER_SAMPLES.out.vcf,
    )

    FILTER_PRIOR(
      meta,
      vcf,
      tbi,
      FILTER_PASS.out.vcf,
      FILTER_PASS.out.tbi,
    )

    // Adds in new variants called by SAGE
    CONCAT_NEW(
      meta,
      vcf,
      tbi,
      FILTER_PRIOR.out.vcf,
      FILTER_PRIOR.out.tbi,
    )

    SORT(
      meta,
      CONCAT_NEW.out.vcf,
    )

    // Adds SAGE annotations to existing variants called by SAGE
    ANNOTATE(
      meta,
      SORT.out.vcf,
      SORT.out.tbi,
      REORDER_SAMPLES.out.vcf,
      REORDER_SAMPLES.out.tbi,
    )

    //ch_versions = ch_versions.mix(XXX.out.versions)

  emit:
    vcf = ANNOTATE.out.vcf
    tbi = ANNOTATE.out.tbi

    versions = ch_versions // channel: [versions.yml]
}
