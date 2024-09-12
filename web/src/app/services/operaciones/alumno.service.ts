import { Injectable } from '@angular/core';
import { ApiAlumno } from '../apis/api.alumnos.service';

@Injectable()
export class AlumnoServicio {
  constructor(private apiAlumno: ApiAlumno) {}

  obtenerAlumnos(search: string, fec_ini: string, fec_fin: string) {
    return this.apiAlumno.getAlumnos(search, fec_ini, fec_fin);
  }
}
