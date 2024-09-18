import { HttpClient } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { ServerResponse } from "../../interface/serve.model";
import { map } from "rxjs";
import { Alumno } from "../../interface/alumno.model";
const url ='http://localhost:3000/api/alumnos'

@Injectable()
export class ApiAlumno {  

    constructor(private http: HttpClient) {}

    // PARA OBTENER TODOS LOS ALUMNOS
    getAlumnos(search:string, fec_ini:string, fec_fin:string){
        return this.http.post<ServerResponse>(url, {search, fec_ini, fec_fin})
        .pipe(map(res => res.body));
    }

    // PARA AÑADIR UN ALUMNO
    saveAlumno(alumno: Alumno) {
        return this.http.post<ServerResponse>(url+'/add', alumno)
        .pipe(map(res => res.body[0].mensaje))
    }

    // PARA ACTUALIZAR UN ALUMNO
    updateAlumno(alumno: Alumno) {
        return this.http.post<ServerResponse>(url+'/upd', alumno)
        .pipe(map(res => res.body[0].mensaje))
    }

    // PARA ELIMINAR UN ALUMNO
    deleteAlumno(index:number) {
        return this.http.delete<ServerResponse>(url+`/${index}`)
        .pipe(map(res => res.body[0].mensaje))
    }
}