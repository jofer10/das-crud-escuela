PGDMP      5                |            escuela    16.2    16.2     �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    74618    escuela    DATABASE     z   CREATE DATABASE escuela WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Spanish_Spain.1252';
    DROP DATABASE escuela;
                postgres    false            �            1255    74640    ufn_alumnos_del(integer)    FUNCTION     o  CREATE FUNCTION public.ufn_alumnos_del(vp_alum_id integer) RETURNS TABLE(mensaje text)
    LANGUAGE plpgsql
    AS $$
DECLARE
	vl_alum_id integer;
BEGIN
	IF coalesce(vp_alum_id,0)=0 THEN
		RAISE EXCEPTION 'Identificador inválido.'
		USING ERRCODE = 'P0001';
	END IF;
	
	IF NOT EXISTS (select 1 from alumnos where alum_id=vp_alum_id) THEN
		RAISE EXCEPTION 'Alumno no registrado en el sistema.'
		USING ERRCODE = 'P0001';
	END IF;
	
	vl_alum_id:=vp_alum_id;
	
	UPDATE alumnos
	SET alum_estado=false
	WHERE alum_id=vp_alum_id;
	
	RETURN QUERY SELECT 'Alumno eliminado exitósamente. ID: '||vl_alum_id AS mensaje;
	
END;
$$;
 :   DROP FUNCTION public.ufn_alumnos_del(vp_alum_id integer);
       public          postgres    false            �            1255    74639 h   ufn_alumnos_ins_upd(integer, character varying, character varying, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.ufn_alumnos_ins_upd(vp_alum_id integer, vp_alum_codigo character varying, vp_alum_dni character varying, vp_alum_apellidos character varying, vp_alum_nombres character varying) RETURNS TABLE(mensaje text)
    LANGUAGE plpgsql
    AS $$
DECLARE
	vl_alum_id integer;
BEGIN
	IF coalesce(vp_alum_codigo,'')='' THEN
		RAISE EXCEPTION 'Código de alumno vacio.'
		USING ERRCODE = 'P0001';
	END IF;
	
	IF coalesce(vp_alum_dni,'')='' THEN
		RAISE EXCEPTION 'DNI en blanco.'
		USING ERRCODE = 'P0001';
	END IF;
	
	IF coalesce(vp_alum_apellidos,'')='' THEN
		RAISE EXCEPTION 'Apellidos vacios.'
		USING ERRCODE = 'P0001';
	END IF;
	
	IF coalesce(vp_alum_nombres,'')='' THEN
		RAISE EXCEPTION 'Nombres vacios.'
		USING ERRCODE = 'P0001';
	END IF;
	
	IF EXISTS   (
					select 1 from alumnos where alum_dni=vp_alum_dni
					and case when vp_alum_id=0 then alum_id=alum_id else alum_id not in(vp_alum_id) end
				) THEN
		RAISE EXCEPTION 'DNI ya existe en otro alumno.'
		USING ERRCODE = 'P0001';
	END IF;
	
	IF EXISTS   (
					select 1 from alumnos where alum_codigo=vp_alum_codigo
					and case when vp_alum_id=0 then alum_id=alum_id else alum_id not in(vp_alum_id) end
				) THEN
		RAISE EXCEPTION 'El código ya existe en otro alumno.'
		USING ERRCODE = 'P0001';
	END IF;
	
	IF vp_alum_id=0 THEN
		INSERT INTO alumnos(alum_codigo,alum_dni,alum_nombres,alum_apellidos,alum_fec_registro,alum_estado)
		VALUES(vp_alum_codigo,vp_alum_dni,vp_alum_nombres,vp_alum_apellidos,now(),true)
		RETURNING alumnos.alum_id INTO vl_alum_id;
		
		RETURN QUERY SELECT 'Alumno creado exitósamente. ID: '||vl_alum_id AS mensaje;
	ELSE
		vl_alum_id:=vp_alum_id;
		
		UPDATE alumnos
		SET alum_codigo=vp_alum_codigo,
			alum_dni=vp_alum_dni,
			alum_nombres=vp_alum_nombres,
			alum_apellidos=vp_alum_apellidos
		WHERE alum_id=vl_alum_id;
		
		RETURN QUERY SELECT 'Alumno actualizado exitósamente. ID: '||vl_alum_id AS mensaje;
	END IF;
END;
$$;
 �   DROP FUNCTION public.ufn_alumnos_ins_upd(vp_alum_id integer, vp_alum_codigo character varying, vp_alum_dni character varying, vp_alum_apellidos character varying, vp_alum_nombres character varying);
       public          postgres    false            �            1255    74638 I   ufn_alumnos_list(character varying, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.ufn_alumnos_list(vp_search character varying, vp_fec_ini character varying, vp_fec_fin character varying) RETURNS TABLE(alum_id integer, alum_codigo character varying, alum_dni character, nombres text, alum_apellidos character varying, alum_nombres character varying, alum_fec_registro text)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT al.alum_id, al.alum_codigo, al.alum_dni, al.alum_apellidos||', '||al.alum_nombres nombres,
	al.alum_apellidos, al.alum_nombres, to_char(al.alum_fec_registro,'dd/MM/yyyy HH:MI:SS') alum_fec_registro
	FROM alumnos al
	WHERE al.alum_fec_registro::date between vp_fec_ini::date and vp_fec_fin::date
	AND al.alum_estado=true
	AND (
		al.alum_codigo LIKE '%'||UPPER(vp_search)||'%' OR
		al.alum_dni LIKE '%'||UPPER(vp_search)||'%' OR
		UPPER(al.alum_nombres) LIKE '%'||UPPER(vp_search)||'%' OR
		UPPER(al.alum_apellidos) LIKE '%'||UPPER(vp_search)||'%'
	)
	ORDER BY 1;
END;
$$;
 �   DROP FUNCTION public.ufn_alumnos_list(vp_search character varying, vp_fec_ini character varying, vp_fec_fin character varying);
       public          postgres    false            �            1259    74631    alumnos    TABLE       CREATE TABLE public.alumnos (
    alum_id integer NOT NULL,
    alum_codigo character varying(10),
    alum_dni character(8),
    alum_nombres character varying(50),
    alum_apellidos character varying(50),
    alum_fec_registro timestamp without time zone,
    alum_estado boolean
);
    DROP TABLE public.alumnos;
       public         heap    postgres    false            �            1259    74630    alumnos_alum_id_seq    SEQUENCE     �   CREATE SEQUENCE public.alumnos_alum_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.alumnos_alum_id_seq;
       public          postgres    false    216            �           0    0    alumnos_alum_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.alumnos_alum_id_seq OWNED BY public.alumnos.alum_id;
          public          postgres    false    215                       2604    74634    alumnos alum_id    DEFAULT     r   ALTER TABLE ONLY public.alumnos ALTER COLUMN alum_id SET DEFAULT nextval('public.alumnos_alum_id_seq'::regclass);
 >   ALTER TABLE public.alumnos ALTER COLUMN alum_id DROP DEFAULT;
       public          postgres    false    216    215    216            �          0    74631    alumnos 
   TABLE DATA              COPY public.alumnos (alum_id, alum_codigo, alum_dni, alum_nombres, alum_apellidos, alum_fec_registro, alum_estado) FROM stdin;
    public          postgres    false    216   �       �           0    0    alumnos_alum_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.alumnos_alum_id_seq', 21, true);
          public          postgres    false    215                       2606    74636    alumnos pk_alumnos 
   CONSTRAINT     U   ALTER TABLE ONLY public.alumnos
    ADD CONSTRAINT pk_alumnos PRIMARY KEY (alum_id);
 <   ALTER TABLE ONLY public.alumnos DROP CONSTRAINT pk_alumnos;
       public            postgres    false    216            �   �  x����n�@E��W�l�-�u`$@�^uCē@��	FVQ��K��+(�̆�C޹�D�(~��u>D�D��#|I%�A+mW�Y��ѷشJ�u4N�VC�Y��ǎ�.�.�FP�Zc-�&`Kenp}���f�9�Y�d��r�냟� t��!F��1�6g��F�f�i���.=g���i�-T����v�T�O��:�#�5{ݍ����(VsA�-:���@���
kAH�p�O��v:u�,�YV���Y ;F�}.l���a��zF%g.29��X��{Ir��'3�%'� !���{����fT�'����66�\΁�6���c:���\,zgtl�4x;����1��D�uk��4�h�������ºˍ�74t��7}�1+*5<POg*���]]lMX�b�,MU����q|͜��2|[WU��S��     