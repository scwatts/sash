process GENERATE_STATS {
  //conda (params.enable_conda ? "XXX" : null)
  //container 'XXX'

  input:
  val meta
  path vcf
  path vcf_full
  path subset_stats

  output:
  path '*.yml'       , emit: stats
  path 'versions.yml', emit: versions

  when:
  task.ext.when == null || task.ext.when

  script:
  def args = task.ext.args ?: ''

  """
  bolt smlv_somatic generate_stats \
    --tumor_name ${meta.tumor_name} \
    --smlv_vcf ${vcf} \
    --smlv_vcf_with_alts ${vcf_full} \
    --highly_mutated_stats ${subset_stats} \
    --output_fp somatic_stats.yml

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
