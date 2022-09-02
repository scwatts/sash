process PREPARE_SMLV_VCF {
  //conda (params.enable_conda ? "XXX" : null)
  //container 'XXX'

  input:
  val meta
  path vcf

  output:
  path '*.vcf.gz'    , emit: vcf
  path 'versions.yml', emit: versions

  when:
  task.ext.when == null || task.ext.when

  script:
  def args = task.ext.args ?: ''

  """
  bolt cnv prepare_smlv_vcf \
    --subject ${meta.id} \
    --tumor_name ${meta.tumor_name} \
    --smlv_somatic_vcf ${vcf} \
    --output_fp prepared.vcf.gz

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
