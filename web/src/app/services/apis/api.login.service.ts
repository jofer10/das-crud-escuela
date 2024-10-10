import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { ServerResponse } from '../../interface/serve.model';
import { map } from 'rxjs';
const url = 'http://localhost:3001/api/login';

@Injectable()
export class Apilogin {
  constructor(private http: HttpClient) {}

  //POST
  login(obj: any) {
    return this.http.post<ServerResponse>(url, obj).pipe(map((res) => res.body[0]));
  }
}
