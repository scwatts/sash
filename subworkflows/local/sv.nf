include { FILTER_INITIAL } from '../../modules/local/sv/filter_initial/main'
include { SNPEFF } from '../../modules/local/sv/snpeff/main'
include { VEP } from '../../modules/local/sv/vep/main'
include { PROCESS_SNPEFF_ANNOTATIONS } from '../../modules/local/sv/process_snpeff_annotations/main'
include { SV_PRIORITIZE } from '../../modules/local/sv/sv_prioritize/main'
include { SUBSET } from '../../modules/local/sv/subset/main'
include { BPI } from '../../modules/local/sv/bpi/main'
include { FILTER } from '../../modules/local/sv/filter/main'
include { REPRIORITIZE_SV } from '../../modules/local/sv/reprioritize_sv/main'
include { GENERATE_TSV } from '../../modules/local/sv/generate_tsv/main'


include { CNV } from './cnv'

workflow SV {
  take:
    meta
    smlv_somatic_vcf
    params

  main:
    // Channel for version.yml files
    ch_versions = Channel.empty()

    // NOTE(SW): check where this is actually used
    //VEP(
    //  meta,
    //  params.input.sv_vcf,
    //  params.refdata.pcgr_dir,
    //)

    FILTER_INITIAL(
      meta,
      params.input.sv_vcf,
    )

    // TODO(SW): check whether snpeff should be run; skip if contains INFO/ANN
    // if (has_info_ann_field(params.input.sv_vcf)) {
    //   vep_input = params.input.sv_vcf
    // else {
    //   SNPEFF()
    //   PROCESS_SNPEFF_ANNOTATIONS()
    //   prioritize_input = PROCESS_SNPEFF_ANNOTATIONS.out.vcf
    // }
    // NOTE(SW): never run with DRAGEN inputs
    SNPEFF(
      meta,
      FILTER_INITIAL.out.vcf,
      FILTER_INITIAL.out.tbi,
      params.refdata.snpeff_db_name,
      params.refdata.snpeff_db_dir,
    )

    PROCESS_SNPEFF_ANNOTATIONS(
      meta,
      SNPEFF.out.vcf,
    )

    SV_PRIORITIZE(
      meta,
      PROCESS_SNPEFF_ANNOTATIONS.out.vcf,
      params.refdata.known_fusion_pairs,
      params.refdata.known_fusion_heads,
      params.refdata.known_fusion_tails,
      params.refdata.fusioncatcher_pairs,
      params.refdata.key_genes_txt,
      params.refdata.key_tsgenes_txt,
      params.refdata.bed_annotations_appris,
    )

    // TODO(SW): get variant count and run subset if required; use fork or similar operator
    SUBSET(
      meta,
      SV_PRIORITIZE.out.vcf,
    )

    // TODO(SW): determine if BPI should be run; check for 'BPI_AF' + 'INFO' and follow as above
    // NOTE(SW): never run with DRAGEN inputs
    BPI(
      meta,
      SUBSET.out.vcf,
      params.input.tumor_bam,
      params.input.normal_bam,
    )

    FILTER(
      meta,
      BPI.out.vcf,
    )

    CNV(
      meta,
      FILTER.out.vcf,
      smlv_somatic_vcf,
      params,
    )

    REPRIORITIZE_SV(
      meta,
      CNV.out.purple_sv_vcf,
      params.refdata.known_fusion_pairs,
      params.refdata.known_fusion_heads,
      params.refdata.known_fusion_tails,
      params.refdata.fusioncatcher_pairs,
      params.refdata.key_genes_txt,
      params.refdata.key_tsgenes_txt,
      params.refdata.bed_annotations_appris,
    )

    // NOTE(SW): we ignore copy_sv_vcf_ffpe_mode since it is not currently being used due to switch from bcbio to
    // DRAGEN. This rule appears only to serve to avoid including numerous PURPLE inferred SVs but as a side-effect
    // discards all PURPLE annotations for SVs. A better method would be to take the PURPLE annotated SV VCF and filter
    // with `bcftools view -f INFERRED` for FFPE samples. Presumably this is trying to solve the problem of having 'too
    // many' SVs, hence a more desirable approach would be to prioritise and select different categories as necessary.

    GENERATE_TSV(
      meta,
      REPRIORITIZE_SV.out.vcf,
    )

  emit:
    vcf = REPRIORITIZE_SV.out.vcf
    tsv = GENERATE_TSV.out.tsv
    purple_cnv_tsv = CNV.out.purple_cnv_tsv

    versions = ch_versions // channel: [versions.yml]
}
