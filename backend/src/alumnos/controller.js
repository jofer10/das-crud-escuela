const debug = require("debug")("app: module-controller-alumnos");
const {Response}=require('../common/response');
const {DataBase}=require('../database');

module.exports.AlumnosController = {
    getAlumnos: async(req,res) => {
        try {
            const {body: {search, fec_ini, fec_fin}}=req

            const {rows} = await DataBase.query("select * from ufn_alumnos_list($1,$2,$3)", [search, fec_ini, fec_fin])
            
            const query = `select * from ufn_alumnos_list('${search}','${fec_ini}','${fec_fin}')`

            console.log(rows);

            Response.success(res, 200, 'Listado de alumnos', rows, query)
        } catch (error) {
            debug(error);
            Response.error(res, error);
        }
    },
    createAlumno: async(req, res)=>{
        try {
            const {body:{alum_id,alum_codigo,alum_dni,alum_apellidos,alum_nombres}}=req

            const {rows} = await DataBase.query("select * from ufn_alumnos_ins_upd($1,$2,$3,$4,$5)",[alum_id,alum_codigo,alum_dni,alum_apellidos,alum_nombres])

            const query = `select * from ufn_alumnos_ins_upd(${alum_id},'${alum_codigo}','${alum_dni}','${alum_apellidos}','${alum_nombres}')`
            
            // Lo trae como arreglo de un objeto accedo al primer objeto tengo el objeto y quiero obtener su atributo.
            console.log(rows[0].mensaje);

            Response.success(res, 200, 'Añadir alumno', rows, query)
        } catch (error) {
            debug(error);
            Response.error(res, error);
        }
    },
    updateAlumno: async(req, res)=>{
        try {
            const {body:{alum_id,alum_codigo,alum_dni,alum_apellidos,alum_nombres}}=req

            const {rows} = await DataBase.query("select * from ufn_alumnos_ins_upd($1,$2,$3,$4,$5)",[alum_id,alum_codigo,alum_dni,alum_apellidos,alum_nombres])

            const query = `select * from ufn_alumnos_ins_upd(${alum_id},'${alum_codigo}','${alum_dni}','${alum_apellidos}','${alum_nombres}')`
            
            // Lo trae como arreglo de un objeto accedo al primer objeto tengo el objeto y quiero obtener su atributo.
            console.log(rows[0].mensaje);

            Response.success(res, 200, 'Editar alumno', rows, query)
        } catch (error) {
            debug(error);
            Response.error(res, error);
        }
    },
    deleteAlumno: async(req, res)=>{
        try {
            const {params:{id}}=req

            const {rows} = await DataBase.query("select * from ufn_alumnos_del($1)",[id])

            const query = `select * from ufn_alumnos_del(${id})`
            
            // Lo trae como arreglo de un objeto accedo al primer objeto tengo el objeto y quiero obtener su atributo.
            console.log(rows[0].mensaje);

            Response.success(res, 200, 'Eliminar alumno', rows, query)
        } catch (error) {
            debug(error);
            Response.error(res, error);
        }
    }
}