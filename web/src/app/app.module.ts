import { importProvidersFrom, NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { FormsModule } from '@angular/forms';
import { BussinessComponent } from './bussiness/bussiness.component';
import { ApiAlumno } from './services/apis/api.alumnos.service';
import { AlumnoServicio } from './services/operaciones/alumno.service';
import { HttpClientModule } from '@angular/common/http';
import { LoginComponent } from './login/login.component';
import { Apilogin } from './services/apis/api.login.service';
import { LoginService } from './services/operaciones/login.service';
import { AuthService } from './services/operaciones/auth.service';

@NgModule({
  declarations: [AppComponent, BussinessComponent, LoginComponent],
  imports: [BrowserModule, AppRoutingModule, FormsModule],
  providers: [
    ApiAlumno,
    Apilogin,
    AlumnoServicio,
    LoginService,
    AuthService,
    importProvidersFrom(HttpClientModule),
  ],
  bootstrap: [AppComponent],
})
export class AppModule {}
