process GENERATE_BAF_PLOT {
  //conda (params.enable_conda ? "XXX" : null)
  //container 'XXX'

  input:
  val meta
  path purple_dir
  path circos_conf
  path circos_gaps

  output:
  path 'circos_baf/*png', emit: png
  path 'versions.yml'   , emit: versions

  when:
  task.ext.when == null || task.ext.when

  script:
  def args = task.ext.args ?: ''

  """
  bolt cnv generate_baf_plot \
    --subject ${meta.id} \
    --purple_circos_dir ${purple_dir}/circos \
    --circos_conf ${circos_conf} \
    --circos_gaps ${circos_gaps} \
    --output_dir circos_baf/

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
