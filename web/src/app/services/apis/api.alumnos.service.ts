import { HttpClient } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { ServerResponse } from "../../interface/serve.model";
import { map } from "rxjs";
const url ='http://localhost:3000/api/alumnos'

@Injectable()
export class ApiAlumno {
    

    constructor(private http: HttpClient) {}

    //GET
    getAlumnos(search:string, fec_ini:string, fec_fin:string){
        return this.http.post<ServerResponse>(url, {search, fec_ini, fec_fin})
        .pipe(map(res => res.body));
    }
}