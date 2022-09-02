#!/usr/bin/env nextflow


include { SASH } from './workflows/sash'


workflow {
  SASH()
}
