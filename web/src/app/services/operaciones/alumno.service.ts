import { Injectable } from '@angular/core';
import { ApiAlumno } from '../apis/api.alumnos.service';
import { Alumno } from '../../interface/alumno.model';

@Injectable()
export class AlumnoServicio {
  constructor(private apiAlumno: ApiAlumno) {}

  obtenerAlumnos(search: string, fec_ini: string, fec_fin: string) {
    return this.apiAlumno.getAlumnos(search, fec_ini, fec_fin);
  }

  guardarAlumno(alumno: Alumno) {
    return this.apiAlumno.saveAlumno(alumno);
  }

  actualizarAlumno(alumno: Alumno) {
    return this.apiAlumno.updateAlumno(alumno);
  }

  eliminarAlumno(index: number) {
    return this.apiAlumno.deleteAlumno(index);
  }
}
