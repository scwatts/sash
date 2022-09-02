process PIERIAN {
  //conda (params.enable_conda ? "XXX" : null)
  //container 'XXX'

  input:
  val meta
  val smlv_vcf
  val cnv_tsv

  output:
  path '*.somatic-PASS-single.grch38.vcf.gz', emit: smlv_vcf
  path '*.purple.cnv'                       , emit: purple_cnv
  path 'versions.yml'                       , emit: versions

  when:
  task.ext.when == null || task.ext.when

  script:
  def args = task.ext.args ?: ''

  """
  bolt misc pierian \
    --tumor_name ${meta.tumor_name} \
    --smlv_vcf ${smlv_vcf} \
    --cnv_tsv ${cnv_tsv} \
    --output_smlv_vcf ${meta.subject}.somatic-PASS-single.grch38.vcf.gz \
    --output_cnv_tsv ${meta.subject}.purple.cnv

  cat <<-END_VERSIONS > versions.yml
    "${task.process}":
      bolt: \$(bolt --version | cut -f3 -d' ')
  END_VERSIONS
  """

  stub:
  """
  echo -e '${task.process}:\\n  stub: noversions\\n' > versions.yml
  """
}
