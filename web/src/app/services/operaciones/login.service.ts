import { Injectable } from '@angular/core';
import { Apilogin } from '../apis/api.login.service';

@Injectable()
export class LoginService {
  constructor(private apiLogin: Apilogin) {}

  isLogin(obj: any) {
    return this.apiLogin.login(obj);
  }
}
