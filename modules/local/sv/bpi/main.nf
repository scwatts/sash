process BPI {
  //conda (params.enable_conda ? "XXX" : null)
  //container 'XXX'

  // TODO(SW): temp
  //memory = 8.GB

  input:
  val meta
  path vcf
  path tumor_bam
  path normal_bam

  output:
  path '*.vcf.gz'    , emit: vcf
  path 'versions.yml', emit: versions

  when:
  task.ext.when == null || task.ext.when

  script:
  def args = task.ext.args ?: ''

  """
  bolt sv bpi \
    --sv_vcf ${vcf} \
    --tumor_bam ${tumor_bam} \
    --normal_bam ${normal_bam} \
    --memory ${task.memory.giga} \
    --temp_dir bpi_tmp/ \
    --output_fp bpi.vcf.gz

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
