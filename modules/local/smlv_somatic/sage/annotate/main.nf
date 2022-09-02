process ANNOTATE {
  //conda (params.enable_conda ? "XXX" : null)
  //container 'XXX'

  input:
  val meta
  path sage_combined_vcf
  path sage_combined_tbi
  path sage_only_vcf
  path sage_only_tbi

  output:
  path '*vcf.gz'     , emit: vcf
  path '*tbi'        , emit: tbi
  path 'versions.yml', emit: versions

  when:
  task.ext.when == null || task.ext.when

  script:
  def args = task.ext.args ?: ''

  """
  bolt smlv_somatic sage/annotate \
    --sage_combined_smlv_vcf ${sage_combined_vcf} \
    --sage_only_smlv_vcf ${sage_only_vcf} \
    --output_fp annotated.vcf.gz

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
