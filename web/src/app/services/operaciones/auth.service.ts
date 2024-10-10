import { Injectable } from "@angular/core";

@Injectable()
export class AuthService {
    
    isLoggedIn(){
        return localStorage.getItem('user')
    }

    isLoggedIn1(){
        return !!localStorage.getItem('user')
    }

    login(obj: any) {
        localStorage.setItem('user',JSON.stringify(obj))
    }

    logout() {
        localStorage.removeItem('user');
    }
}