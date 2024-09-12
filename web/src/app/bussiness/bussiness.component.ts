import { Component } from '@angular/core';
import { AlumnoServicio } from '../services/operaciones/alumno.service';
import { Alumno } from '../interface/alumno.model';

@Component({
  selector: 'app-bussiness',
  templateUrl: './bussiness.component.html',
  styleUrl: './bussiness.component.css'
})
export class BussinessComponent {
  listAlumnos: Alumno[]
  search: string;
  desde: string;
  hasta: string;
  vl_fec_ini: string;
  vl_fec_fin: string;

  constructor(private alumnoService: AlumnoServicio){
    // Fecha de hoy
    const hoy = new Date();
    
    // Formatear la fecha de hoy para "Hasta"
    this.hasta = this.formatearFecha(hoy);

    // Restar 15 días a la fecha de hoy para "Desde"
    const hace15Dias = new Date();
    hace15Dias.setDate(hoy.getDate() - 15);
    this.desde = this.formatearFecha(hace15Dias);
    
    // FORMATEAR
    const arrayFecIni = this.desde.split('-') 
    const arrayFecFin= this.hasta.split('-')
    this.vl_fec_ini=`${arrayFecIni[2]}/${arrayFecIni[1]}/${arrayFecIni[0]}`
    this.vl_fec_fin=`${arrayFecFin[2]}/${arrayFecFin[1]}/${arrayFecFin[0]}`
    this.search=``

    alumnoService.obtenerAlumnos(this.search,this.vl_fec_ini,this.vl_fec_fin).subscribe(
      res => {
        this.listAlumnos=res;
        console.log(this.listAlumnos);
      }
    )
  }

  // Método para formatear la fecha en formato YYYY-MM-DD para los campos de tipo "date"
  formatearFecha(fecha: Date): string {
    const año = fecha.getFullYear();
    const mes = ('0' + (fecha.getMonth() + 1)).slice(-2);  // Asegurar que sea de 2 dígitos
    const dia = ('0' + fecha.getDate()).slice(-2);  // Asegurar que sea de 2 dígitos
    return `${año}-${mes}-${dia}`;
  }

  buscar(){
    const arrayFecIni = this.desde.split('-') 
    const arrayFecFin= this.hasta.split('-')
    this.vl_fec_ini=`${arrayFecIni[2]}/${arrayFecIni[1]}/${arrayFecIni[0]}`
    this.vl_fec_fin=`${arrayFecFin[2]}/${arrayFecFin[1]}/${arrayFecFin[0]}`
    
    this.search= this.search === undefined?'':this.search
    console.log('Buscador: '+this.search);

    console.log("Fecha desde formateada: "+this.vl_fec_ini+"\nFecha hasta formateada: "+this.vl_fec_fin);
    
    console.log("Fecha desde: "+this.desde+" Tipo: "+typeof this.desde);
    console.log("Fecha hasta: "+this.hasta+" Tipo: "+typeof this.hasta);

    this.alumnoService.obtenerAlumnos(this.search,this.vl_fec_ini,this.vl_fec_fin).subscribe(
      res => {
        this.listAlumnos=res;
        console.log("Busqueda por filtro");
        console.log(this.listAlumnos);
      }
    )
  }
}
