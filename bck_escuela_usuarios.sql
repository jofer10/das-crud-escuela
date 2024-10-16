PGDMP  	        	        	    |            escuela_usuarios    16.2    16.2 &    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    80398    escuela_usuarios    DATABASE     �   CREATE DATABASE escuela_usuarios WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Spanish_Spain.1252';
     DROP DATABASE escuela_usuarios;
                postgres    false                        3079    80451    pgcrypto 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
    DROP EXTENSION pgcrypto;
                   false            �           0    0    EXTENSION pgcrypto    COMMENT     <   COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';
                        false    2                       1255    80492 D   ufn_login_usuario_add(character varying, integer, character varying)    FUNCTION       CREATE FUNCTION public.ufn_login_usuario_add(vp_correo character varying, vp_per_id integer, vp_usu_key_access character varying) RETURNS TABLE(mensaje text)
    LANGUAGE plpgsql
    AS $$
DECLARE
	vl_mail_cuenta	character varying:=substr(vp_correo,1,position('@' IN vp_correo)-1);
	vl_mail_dominio character varying:=substr(vp_correo,position('@' IN vp_correo)+1);
	vl_usu_id		integer;
BEGIN
	IF coalesce(vp_correo,'')='' THEN
		RAISE EXCEPTION 'Error: Correo en blanco.'
		USING ERRCODE = 'P0001';
	END IF;
	
	IF coalesce(vp_per_id,0)=0 THEN
		RAISE EXCEPTION 'Error: Personal no válido.'
		USING ERRCODE = 'P0001';
	END IF;
	
	IF coalesce(vp_usu_key_access,'')='' THEN
		RAISE EXCEPTION 'Error: Password en blanco.'
		USING ERRCODE = 'P0001';
	END IF;
	
	IF EXISTS
	(
		select 1
		from emails em
		where em.mail_cuenta||'@'||em.mail_dominio=lower(vp_correo)
	) THEN
		RAISE EXCEPTION 'Error: EL correo ingresado ya existe.'
		USING ERRCODE = 'P0001';
	END IF;
	
	select u.usu_id
	into vl_usu_id
	from usuarios u
	where u.per_id=vp_per_id;
	
	IF coalesce(vl_usu_id,0)=0 THEN
		INSERT INTO emails(mail_cuenta,mail_dominio,mail_registro,mail_estado)
		VALUES(lower(vl_mail_cuenta),lower(vl_mail_dominio),now(),true);

		INSERT INTO usuarios(email_id,per_id,usu_estado)
		VALUES(lastval(),vp_per_id,true)
		RETURNING usuarios.usu_id INTO vl_usu_id;

		INSERT INTO usuarios_key(usu_id,usu_key_access,key_registro,key_estado)
		VALUES(vl_usu_id,vp_usu_key_access,now(),true);
	ELSE
		RAISE EXCEPTION 'Error: Ya tiene un usuario creado.'
		USING ERRCODE = 'P0001';
	END IF;
	
	RETURN QUERY SELECT 'Usuario creado exitósamente. ID: '||vl_usu_id AS mensaje;
END;
$$;
 �   DROP FUNCTION public.ufn_login_usuario_add(vp_correo character varying, vp_per_id integer, vp_usu_key_access character varying);
       public          postgres    false                       1255    80494 .   ufn_login_validacion_correo(character varying)    FUNCTION     �  CREATE FUNCTION public.ufn_login_validacion_correo(vp_correo character varying) RETURNS TABLE(usu_key_access character varying, usu_id integer, per_nombre character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
	vl_usu_id			integer;
	vl_usu_key_access 	character varying;
	vl_fec_vence		date;
	vl_per_nombre		character varying;
BEGIN
	IF coalesce(vp_correo,'')='' THEN
		RAISE EXCEPTION 'Error: Correo en blanco.'
		USING ERRCODE = 'P0001';
	END IF;
	
	select u.usu_id, uk.usu_key_access, uk.fec_vence
	into vl_usu_id, vl_usu_key_access, vl_fec_vence
	from emails em
	inner join usuarios u on u.email_id = em.email_id
	inner join usuarios_key uk on uk.usu_id = u.usu_id
	where em.mail_cuenta||'@'||em.mail_dominio = lower(vp_correo) and uk.key_estado = true;
	
	select case when per.per_nombre='Sistemas' then 'ADMINISTRADOR' else per.per_nombre end
	into vl_per_nombre
	from usuarios u
	inner join personal per on (per.per_id=u.per_id)
	where u.usu_id=vl_usu_id;
	
	IF (NOW())::date > vl_fec_vence  
	THEN
		RAISE EXCEPTION 'Su clave ha vencido. Notificar al administrador para que cambie la contraseña.'
		USING ERRCODE = 'P0001';
	END IF;
	
	RETURN QUERY 
	SELECT coalesce(vl_usu_key_access,''), vl_usu_id, vl_per_nombre;
END;
$$;
 O   DROP FUNCTION public.ufn_login_validacion_correo(vp_correo character varying);
       public          postgres    false                       1255    80489    ufn_personal_del(integer)    FUNCTION     �  CREATE FUNCTION public.ufn_personal_del(vp_per_id integer) RETURNS TABLE(mensaje text)
    LANGUAGE plpgsql
    AS $$
BEGIN
	-- VALIDAR QUE EL DNI SEA UNICO
	IF NOT EXISTS
	(
		select 1
		from personal per
		where per.per_id=vp_per_id
	) THEN
		RAISE EXCEPTION 'Error: No existe el personal a eliminar.'
		USING ERRCODE = 'P0001';
	END IF;
	
	
	UPDATE personal
	SET per_estado=false
	WHERE per_id=vp_per_id;
	
	RETURN QUERY SELECT 'Personal eliminado exitósamente. ID: '||vp_per_id AS mensaje;
END;
$$;
 :   DROP FUNCTION public.ufn_personal_del(vp_per_id integer);
       public          postgres    false                       1255    80488 V   ufn_personal_ins_upd(integer, character varying, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.ufn_personal_ins_upd(vp_per_id integer, vp_per_nrodoc character varying, vp_per_apellido character varying, vp_per_nombre character varying) RETURNS TABLE(mensaje text)
    LANGUAGE plpgsql
    AS $$
DECLARE
	vl_per_id	integer;
BEGIN
	-- VALIDAR QUE EL DNI SEA UNICO
	IF EXISTS
	(
		select 1
		from personal per
		where trim(per.per_nrodoc)=trim(vp_per_nrodoc)
		AND case when coalesce(vp_per_id,0)=0 then true else per.per_id not in(vp_per_id) end
	) THEN
		RAISE EXCEPTION 'Error: DNI ya existe.'
		USING ERRCODE = 'P0001';
	END IF;
	
	IF coalesce(vp_per_id,0)=0 THEN
		INSERT INTO personal(per_nrodoc,per_apellido,per_nombre,per_estado)
		VALUES(vp_per_nrodoc, upper(vp_per_apellido),upper(vp_per_nombre),true)
		RETURNING personal.per_id INTO vl_per_id;
		
		RETURN QUERY SELECT 'Personal agregado exitósamente. ID: '||vl_per_id AS mensaje;
	ELSE
		vl_per_id:=vp_per_id;
		
		UPDATE personal
		SET per_nrodoc=vp_per_nrodoc,
			per_apellido=upper(vp_per_apellido),
			per_nombre=upper(vp_per_nombre)
		WHERE per_id=vl_per_id;
		
		RETURN QUERY SELECT 'Personal actualizado exitósamente. ID: '||vl_per_id AS mensaje;
	END IF;
END;
$$;
 �   DROP FUNCTION public.ufn_personal_ins_upd(vp_per_id integer, vp_per_nrodoc character varying, vp_per_apellido character varying, vp_per_nombre character varying);
       public          postgres    false                       1255    80493 $   ufn_personal_list(character varying)    FUNCTION     �  CREATE FUNCTION public.ufn_personal_list(vp_search character varying) RETURNS TABLE(per_id integer, per_nrodoc character, per_apellido character varying, per_nombre character varying, nombres text, usu_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT per.per_id, per.per_nrodoc, per.per_apellido, per.per_nombre, per.per_apellido||', '||per.per_nombre nombres, coalesce(u.usu_id,0) usu_id
	FROM personal per
	LEFT JOIN usuarios u on u.per_id=per.per_id
	WHERE per.per_estado = true AND
	(
		trim(per.per_nrodoc) LIKE '%'||trim(vp_search)||'%' OR
		upper(per.per_apellido) LIKE '%'||upper(vp_search)||'%' OR
		upper(per.per_nombre) LIKE '%'||upper(vp_search)||'%'
	)
	ORDER BY 1;
END;
$$;
 E   DROP FUNCTION public.ufn_personal_list(vp_search character varying);
       public          postgres    false            �            1259    80411    emails    TABLE     �   CREATE TABLE public.emails (
    email_id integer NOT NULL,
    mail_cuenta character varying(60),
    mail_dominio character varying(60),
    mail_registro timestamp without time zone,
    mail_estado boolean
);
    DROP TABLE public.emails;
       public         heap    postgres    false            �            1259    80410    emails_email_id_seq    SEQUENCE     �   CREATE SEQUENCE public.emails_email_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.emails_email_id_seq;
       public          postgres    false    217            �           0    0    emails_email_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.emails_email_id_seq OWNED BY public.emails.email_id;
          public          postgres    false    216            �            1259    80430    personal    TABLE     �   CREATE TABLE public.personal (
    per_id integer NOT NULL,
    per_nrodoc character(8),
    per_apellido character varying(60),
    per_nombre character varying(60),
    per_estado boolean
);
    DROP TABLE public.personal;
       public         heap    postgres    false            �            1259    80429    personal_per_id_seq    SEQUENCE     �   CREATE SEQUENCE public.personal_per_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.personal_per_id_seq;
       public          postgres    false    221            �           0    0    personal_per_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.personal_per_id_seq OWNED BY public.personal.per_id;
          public          postgres    false    220            �            1259    80418    usuarios    TABLE     �   CREATE TABLE public.usuarios (
    usu_id integer NOT NULL,
    email_id integer,
    per_id integer,
    usu_estado boolean
);
    DROP TABLE public.usuarios;
       public         heap    postgres    false            �            1259    80441    usuarios_key    TABLE     �   CREATE TABLE public.usuarios_key (
    usu_id integer NOT NULL,
    usu_key_access character(60),
    key_registro timestamp without time zone,
    key_estado boolean,
    fec_vence date
);
     DROP TABLE public.usuarios_key;
       public         heap    postgres    false            �            1259    80417    usuarios_usu_id_seq    SEQUENCE     �   CREATE SEQUENCE public.usuarios_usu_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.usuarios_usu_id_seq;
       public          postgres    false    219            �           0    0    usuarios_usu_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.usuarios_usu_id_seq OWNED BY public.usuarios.usu_id;
          public          postgres    false    218            R           2604    80414    emails email_id    DEFAULT     r   ALTER TABLE ONLY public.emails ALTER COLUMN email_id SET DEFAULT nextval('public.emails_email_id_seq'::regclass);
 >   ALTER TABLE public.emails ALTER COLUMN email_id DROP DEFAULT;
       public          postgres    false    216    217    217            T           2604    80433    personal per_id    DEFAULT     r   ALTER TABLE ONLY public.personal ALTER COLUMN per_id SET DEFAULT nextval('public.personal_per_id_seq'::regclass);
 >   ALTER TABLE public.personal ALTER COLUMN per_id DROP DEFAULT;
       public          postgres    false    220    221    221            S           2604    80421    usuarios usu_id    DEFAULT     r   ALTER TABLE ONLY public.usuarios ALTER COLUMN usu_id SET DEFAULT nextval('public.usuarios_usu_id_seq'::regclass);
 >   ALTER TABLE public.usuarios ALTER COLUMN usu_id DROP DEFAULT;
       public          postgres    false    219    218    219            �          0    80411    emails 
   TABLE DATA           a   COPY public.emails (email_id, mail_cuenta, mail_dominio, mail_registro, mail_estado) FROM stdin;
    public          postgres    false    217   �=       �          0    80430    personal 
   TABLE DATA           \   COPY public.personal (per_id, per_nrodoc, per_apellido, per_nombre, per_estado) FROM stdin;
    public          postgres    false    221   �>       �          0    80418    usuarios 
   TABLE DATA           H   COPY public.usuarios (usu_id, email_id, per_id, usu_estado) FROM stdin;
    public          postgres    false    219   @       �          0    80441    usuarios_key 
   TABLE DATA           c   COPY public.usuarios_key (usu_id, usu_key_access, key_registro, key_estado, fec_vence) FROM stdin;
    public          postgres    false    222   b@                   0    0    emails_email_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.emails_email_id_seq', 11, true);
          public          postgres    false    216                       0    0    personal_per_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.personal_per_id_seq', 13, true);
          public          postgres    false    220                       0    0    usuarios_usu_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.usuarios_usu_id_seq', 11, true);
          public          postgres    false    218            V           2606    80416    emails pk_emails 
   CONSTRAINT     T   ALTER TABLE ONLY public.emails
    ADD CONSTRAINT pk_emails PRIMARY KEY (email_id);
 :   ALTER TABLE ONLY public.emails DROP CONSTRAINT pk_emails;
       public            postgres    false    217            Z           2606    80435    personal pk_personal 
   CONSTRAINT     V   ALTER TABLE ONLY public.personal
    ADD CONSTRAINT pk_personal PRIMARY KEY (per_id);
 >   ALTER TABLE ONLY public.personal DROP CONSTRAINT pk_personal;
       public            postgres    false    221            X           2606    80423    usuarios pk_usuarios 
   CONSTRAINT     V   ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT pk_usuarios PRIMARY KEY (usu_id);
 >   ALTER TABLE ONLY public.usuarios DROP CONSTRAINT pk_usuarios;
       public            postgres    false    219            \           2606    80445    usuarios_key pk_usuarios_key 
   CONSTRAINT     ^   ALTER TABLE ONLY public.usuarios_key
    ADD CONSTRAINT pk_usuarios_key PRIMARY KEY (usu_id);
 F   ALTER TABLE ONLY public.usuarios_key DROP CONSTRAINT pk_usuarios_key;
       public            postgres    false    222            ]           2606    80424    usuarios fk_email_id    FK CONSTRAINT     {   ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT fk_email_id FOREIGN KEY (email_id) REFERENCES public.emails(email_id);
 >   ALTER TABLE ONLY public.usuarios DROP CONSTRAINT fk_email_id;
       public          postgres    false    219    4694    217            ^           2606    80436    usuarios fk_per_id    FK CONSTRAINT     w   ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT fk_per_id FOREIGN KEY (per_id) REFERENCES public.personal(per_id);
 <   ALTER TABLE ONLY public.usuarios DROP CONSTRAINT fk_per_id;
       public          postgres    false    4698    219    221            _           2606    80446    usuarios_key fk_usu_id    FK CONSTRAINT     {   ALTER TABLE ONLY public.usuarios_key
    ADD CONSTRAINT fk_usu_id FOREIGN KEY (usu_id) REFERENCES public.usuarios(usu_id);
 @   ALTER TABLE ONLY public.usuarios_key DROP CONSTRAINT fk_usu_id;
       public          postgres    false    219    4696    222            �   �   x���M��0F���@-��ҍE2�iW���J]����O~�����Be+�Bę�V۳j��pRz��d:T����1����w�����!�	|ɔ�`Kݯf*�E��P|������7��]	�Q�9H���p���w�
�Fy^��9BzFt���O�ࣗ��E��z*r���73N�L�`׫�b��K!�o�b�4/-N�x      �   3  x�M�MN�0��/��	P�;YZm��� T�qS,�6r�M����vR^Y�oޛyNPp�giB���%i��Q�g=`�RP�$i�e�����[�4�'<��^��Y��IB)��d�S�D��s�8/
���W��s�x�R�z;���gʲ(8gi��������ǬV������>���2�A�U��a�`�+A�Z^�:�J�U������a��
�1��1����c
���]�e�.�SV/�}|�vd���T;��z��V��ج�Z������}���;i�����:���N2���ME?Q]�u      �   ?   x�%̱�@��[����^(�����l���j�P�Sa��\
3f)̭0���<�����˻�b      �   Q  x���9��@ �x�L:@bc�(���Q���"�4
�~7a�v#�|�^=�㓎>�I�e��������zy��m���:Yb���5�Rfˊ7U���}��~��� �-��2��!�����p�̌��F�!F����-]����v��N�� q9�~ �z\̰3S�N�u��A!X�M���Ԍ|_��#t�[:�z݅�Kl���b�+��Y�z���n��8�w��M��қ||��jJ&�W�xt2��5X4��73k=OIA>t�w!��Ii�2����1�Z�T���2��"��}"�s�bf�g4��$U���s�V*V�l\�m��`�c�'�6�i/����Z����凜\Ή_:"9A)|�K���:8�CX5���d�3}%z�Z~~fWJ���� �3��GE\�$�%����)�6����^���z`���f'�NLE����6��U��P�@����_8�������ݽ���[��iC|?^������s�L�q1�9�]��v�lHכCč�p�w6~�-�k��ϙ�>D/�G���ym��#!-�� �v���(U�Rr
��Y��E��xI�w��I�V�_R,�     