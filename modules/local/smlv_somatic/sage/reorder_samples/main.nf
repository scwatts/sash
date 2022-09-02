process REORDER_SAMPLES {
  //conda (params.enable_conda ? "XXX" : null)
  container 'XXX'

  input:
  val meta
  path vcf
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
  bolt smlv_somatic sage/reorder_samples \
    --smlv_vcf ${vcf} \
    --sage_smlv_vcf ${sage_vcf} \
    --output_fp reordered.vcf.gz

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
