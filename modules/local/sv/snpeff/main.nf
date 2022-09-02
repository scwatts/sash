process SNPEFF {
  //conda (params.enable_conda ? "XXX" : null)
  //container 'XXX'

  // NOTE(SW): temp
  //memory = 8.GB
  //cpus = 4

  input:
  val meta
  path vcf
  path tbi
  val refdata_snpeff_db_name
  path refdata_snpeff_db_dir

  output:
  path '*.vcf.gz'    , emit: vcf
  path '*.tbi'       , emit: tbi
  path 'versions.yml', emit: versions

  when:
  task.ext.when == null || task.ext.when

  script:
  def args = task.ext.args ?: ''

  """
  bolt sv snpeff \
    --sv_vcf ${vcf} \
    --snpeff_db_name ${refdata_snpeff_db_name} \
    --snpeff_db_dir \$(pwd -P)/${refdata_snpeff_db_dir} \
    --memory ${task.memory.giga} \
    --threads ${task.cpus} \
    --temp_dir snpeff_tmp/ \
    --output_vcf snpeff.vcf.gz \
    --output_csv snpeff.csv \
    --output_html snpeff.html

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
