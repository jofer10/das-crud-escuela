import { Component } from '@angular/core';
import { AlumnoServicio } from '../services/operaciones/alumno.service';
import { Alumno } from '../interface/alumno.model';
import { NgForm } from '@angular/forms';
import { AuthService } from '../services/operaciones/auth.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-bussiness',
  templateUrl: './bussiness.component.html',
  styleUrl: './bussiness.component.css',
})
export class BussinessComponent {
  listAlumnos: Alumno[];
  search: string;
  desde: string;
  hasta: string;
  vl_fec_ini: string;
  vl_fec_fin: string;
  errorMsg: string;
  mensaje: string;
  alumno: any = {
    alum_id: 0,
    alum_codigo: '',
    alum_dni: '',
    alum_nombres: '',
    alum_apellidos: '',
  };
  validEdit: boolean = false;
  isDelete: boolean = false;
  id: number;

  constructor(private alumnoService: AlumnoServicio, private authService: AuthService, private router: Router) {
    // Fecha de hoy
    const hoy = new Date();

    // Formatear la fecha de hoy para "Hasta"
    this.hasta = this.formatearFecha(hoy);

    // Restar 15 días a la fecha de hoy para "Desde"
    const hace15Dias = new Date();
    hace15Dias.setDate(hoy.getDate() - 15);
    this.desde = this.formatearFecha(hace15Dias);

    // FORMATEAR
    const arrayFecIni = this.desde.split('-');
    const arrayFecFin = this.hasta.split('-');
    this.vl_fec_ini = `${arrayFecIni[2]}/${arrayFecIni[1]}/${arrayFecIni[0]}`;
    this.vl_fec_fin = `${arrayFecFin[2]}/${arrayFecFin[1]}/${arrayFecFin[0]}`;
    this.search = ``;
    
    const responseLogin = JSON.parse(authService.isLoggedIn()!)
    console.log("Datos recibidos desde login - storage: "+responseLogin.per_nombre);

    alumnoService
      .obtenerAlumnos(this.search, this.vl_fec_ini, this.vl_fec_fin)
      .subscribe((res) => {
        this.listAlumnos = res;
        console.log(this.listAlumnos);
      });
  }

  logout(){
    this.authService.logout()
    this.router.navigate(['login'])
  }

  cerrarModal() {
    this.errorMsg = '';
    this.mensaje = '';
    this.validEdit = false;
    this.isDelete = false;
    this.id = 0;
    this.alumno = {
      alum_id: 0,
      alum_codigo: '',
      alum_dni: '',
      alum_nombres: '',
      alum_apellidos: '',
    };
  }

  abrirModal() {
    this.validEdit = true;
  }

  abrirModalEliminar(index: number) {
    this.isDelete = true;
    this.id = index;
  }

  capturarDatos(alumno: Alumno) {
    console.log('Captura del objeto');
    console.log(alumno);

    this.alumno.alum_id = alumno.alum_id;
    this.alumno.alum_codigo = alumno.alum_codigo;
    this.alumno.alum_dni = alumno.alum_dni;
    this.alumno.alum_nombres = alumno.alum_nombres;
    this.alumno.alum_apellidos = alumno.alum_apellidos;
  }

  // Método para formatear la fecha en formato YYYY-MM-DD para los campos de tipo "date"
  formatearFecha(fecha: Date): string {
    const año = fecha.getFullYear();
    const mes = ('0' + (fecha.getMonth() + 1)).slice(-2); // Asegurar que sea de 2 dígitos
    const dia = ('0' + fecha.getDate()).slice(-2); // Asegurar que sea de 2 dígitos
    return `${año}-${mes}-${dia}`;
  }

  buscar() {
    const arrayFecIni = this.desde.split('-');
    const arrayFecFin = this.hasta.split('-');
    this.vl_fec_ini = `${arrayFecIni[2]}/${arrayFecIni[1]}/${arrayFecIni[0]}`;
    this.vl_fec_fin = `${arrayFecFin[2]}/${arrayFecFin[1]}/${arrayFecFin[0]}`;

    this.search = this.search === undefined ? '' : this.search;
    console.log('Buscador: ' + this.search);

    console.log(
      'Fecha desde formateada: ' +
        this.vl_fec_ini +
        '\nFecha hasta formateada: ' +
        this.vl_fec_fin
    );

    console.log('Fecha desde: ' + this.desde + ' Tipo: ' + typeof this.desde);
    console.log('Fecha hasta: ' + this.hasta + ' Tipo: ' + typeof this.hasta);

    this.alumnoService
      .obtenerAlumnos(this.search, this.vl_fec_ini, this.vl_fec_fin)
      .subscribe((res) => {
        this.listAlumnos = res;
        console.log('Busqueda por filtro');
        console.log(this.listAlumnos);
      });
  }

  grabar(form: NgForm) {
    console.log('Nuevo Alumno: \n' + JSON.stringify(this.alumno));

    this.alumnoService.guardarAlumno(this.alumno).subscribe(
      (res) => {
        this.mensaje = res;
        console.log(this.mensaje);
        console.log(this.search + ' ' + this.desde + ' ' + this.hasta);
        form.reset();
        this.alumnoService
          .obtenerAlumnos(this.search, this.vl_fec_ini, this.vl_fec_fin)
          .subscribe((res) => {
            this.listAlumnos = res;
            console.log(
              'Cargando nuevamente el listado despues de añadir alumno.'
            );
            console.log(this.listAlumnos);
          });
      },
      (err) => {
        // Personaliza los mensajes de error aquí
        if (err.status === 0) {
          this.errorMsg =
            'No se pudo conectar con el servidor. Verifica tu conexión.';
        } else if (err.status === 500) {
          this.errorMsg = err.error.message;
        } else if (err.status === 400) {
          this.errorMsg = 'Datos incorrectos enviados al servidor.';
        } else {
          this.errorMsg = 'Ocurrió un error desconocido.';
        }
        form.reset();
        console.log(err.error.message);
        console.error('Error capturado:', this.errorMsg);
      }
    );
    this.cerrarModal();
  }

  editar() {
    console.log(
      'Verificar que los datos se trasladaron correctamente: \n' +
        JSON.stringify(this.alumno)
    );

    this.alumnoService.actualizarAlumno(this.alumno).subscribe(
      (res) => {
        this.mensaje = res;
        console.log(this.mensaje);
        console.log(this.search + ' ' + this.desde + ' ' + this.hasta);

        this.alumnoService
          .obtenerAlumnos(this.search, this.vl_fec_ini, this.vl_fec_fin)
          .subscribe((res) => {
            this.listAlumnos = res;
            console.log(
              'Cargando nuevamente el listado despues de actualizar alumno.'
            );
            console.log(this.listAlumnos);
          });
      },
      (err) => {
        // Personaliza los mensajes de error aquí
        if (err.status === 0) {
          this.errorMsg =
            'No se pudo conectar con el servidor. Verifica tu conexión.';
        } else if (err.status === 500) {
          this.errorMsg = err.error.message;
        } else if (err.status === 400) {
          this.errorMsg = 'Datos incorrectos enviados al servidor.';
        } else {
          this.errorMsg = 'Ocurrió un error desconocido.';
        }

        console.log(err.error.message);
        console.error('Error capturado:', this.errorMsg);
      }
    );
    this.cerrarModal();
  }

  eliminar() {
    console.log("El ID del alumno llega correctamente: "+this.id);

    this.alumnoService.eliminarAlumno(this.id).subscribe(
      (res) => {
        this.mensaje = res;
        console.log(this.mensaje);
        console.log(this.search + ' ' + this.desde + ' ' + this.hasta);

        this.alumnoService
          .obtenerAlumnos(this.search, this.vl_fec_ini, this.vl_fec_fin)
          .subscribe((res) => {
            this.listAlumnos = res;
            console.log(
              'Cargando nuevamente el listado despues de eliminar alumno.'
            );
            console.log(this.listAlumnos);
          });
      },
      (err) => {
        // Personaliza los mensajes de error aquí
        if (err.status === 0) {
          this.errorMsg =
            'No se pudo conectar con el servidor. Verifica tu conexión.';
        } else if (err.status === 500) {
          this.errorMsg = err.error.message;
        } else if (err.status === 400) {
          this.errorMsg = 'Datos incorrectos enviados al servidor.';
        } else {
          this.errorMsg = 'Ocurrió un error desconocido.';
        }

        console.log(err.error.message);
        console.error('Error capturado:', this.errorMsg);
      }
    );
    this.cerrarModal();
  }
}
