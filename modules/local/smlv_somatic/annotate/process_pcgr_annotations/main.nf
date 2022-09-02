process PROCESS_PCGR_ANNOTATIONS {
  //conda (params.enable_conda ? "XXX" : null)
  //container 'XXX'

  input:
  val meta
  path vcf
  path pcgr_tiers
  path pcgr_vcf
  path pcgr_tbi

  output:
  path '*.vcf.gz'    , emit: vcf
  path '*.tbi'       , emit: tbi
  path 'versions.yml', emit: versions

  when:
  task.ext.when == null || task.ext.when

  script:
  def args = task.ext.args ?: ''

  """
  bolt smlv_somatic annotate/process_pcgr_annotations \
    --smlv_vcf ${vcf} \
    --pcgr_tiers ${pcgr_tiers} \
    --pcgr_vcf ${pcgr_vcf} \
    --output_fp annotated_with_pcgr.vcf.gz

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
