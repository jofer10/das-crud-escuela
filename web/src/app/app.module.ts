import { importProvidersFrom, NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { FormsModule } from '@angular/forms';
import { BussinessComponent } from './bussiness/bussiness.component';
import { ApiAlumno } from './services/apis/api.alumnos.service';
import { AlumnoServicio } from './services/operaciones/alumno.service';
import { HttpClientModule } from '@angular/common/http';

@NgModule({
  declarations: [
    AppComponent,
    BussinessComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    FormsModule
  ],
  providers: [ApiAlumno, AlumnoServicio, importProvidersFrom(HttpClientModule)],
  bootstrap: [AppComponent]
})
export class AppModule { }
