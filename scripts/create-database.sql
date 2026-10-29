\set ON_ERROR_STOP on
\prompt 'Usuário da aplicação (ex.: optistock_user): ' app_user
CREATE ROLE :"app_user" LOGIN;
\password :app_user
\prompt 'Nome do banco (ex.: optistock): ' app_db
CREATE DATABASE :"app_db" OWNER :"app_user";
