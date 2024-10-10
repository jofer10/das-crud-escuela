import { Component } from '@angular/core';
import { NgForm } from '@angular/forms';
import { LoginService } from '../services/operaciones/login.service';
import { LoginDTO } from '../interface/loginDTO.model';
import { AuthService } from '../services/operaciones/auth.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrl: './login.component.css'
})
export class LoginComponent {
  loginResponse: LoginDTO
  errorMsg: string

  constructor(private loginService: LoginService, private authService: AuthService, private router: Router){}
  
  login(f: NgForm) {
    var correo = f.value.email
    var password = f.value.password

    const login = {
      correo,
      password
    }
    
    console.log("Datos recibidos desde Login");
    console.log("Correo: "+correo);
    console.log("Password: "+password);

    this.loginService.isLogin(login).subscribe(
      res => {
        this.loginResponse = res
        console.log("Respuesta del servidor: \n"+JSON.stringify(this.loginResponse));
        
        this.authService.login(this.loginResponse)
        console.log("Objeto obtenido desde el storage: "+this.authService.isLoggedIn());
        // console.log("Tipo de dato obtenido desde el storage: "+ typeof this.authService.isLoggedIn());
        
        this.router.navigate(['inicio'])
        // this.authService.logout()
        f.resetForm()
      },
      err => {
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
        alert(this.errorMsg)
        f.reset();
      }
    )
  }
}
