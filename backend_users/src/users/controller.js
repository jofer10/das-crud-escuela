const debug = require("debug")("app: module-users-controller");
const { UserService } = require("./service");
const { Response } = require("../common/response");

module.exports.UserController = {
    verificacionLogin: async(req, res) => {
        try {
            const {body: {correo, password}} = req

            const payload = {
                correo,
                password
            }

            const obj = await UserService.loginValidacion(payload)

            console.log(obj);

            if (obj === null) {
                throw new Error('Correo y/o Contraseña incorrectos.');
            }

            const [rows, query] = obj

            console.log("Lo que devuelve el SP: \n"+JSON.stringify(rows));
            console.log(password);
            console.log(query);

            Response.success(res, 200, 'Retorno de datos de login', rows, query)
        } catch (error) {
            debug(error);
            Response.error(res, error);
        }
    }
};
