process FILTER_PRIOR {
  //conda (params.enable_conda ? "XXX" : null)
  //container 'XXX'

  input:
  val meta
  path vcf
  path tbi
  path sage_vcf
  path sage_tbi

  output:
  path '*.vcf.gz'    , emit: vcf
  path '*.tbi'       , emit: tbi
  path 'versions.yml', emit: versions

  when:
  task.ext.when == null || task.ext.when

  script:
  def args = task.ext.args ?: ''

  """
  bolt smlv_somatic sage/filter_prior \
    --smlv_vcf ${vcf} \
    --sage_smlv_vcf ${sage_vcf} \
    --output_fp filter_prior.vcf.gz

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
