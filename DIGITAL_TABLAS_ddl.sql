CREATE TABLE digital_logs
    (log_id                         NUMBER(10,0) NOT NULL,
    log_app                        VARCHAR2(20 BYTE) NOT NULL,
    log_nivel                      VARCHAR2(100 BYTE) NOT NULL,
    log_mensaje                    VARCHAR2(4000 BYTE) NOT NULL,
    log_ip                         VARCHAR2(50 BYTE) DEFAULT 'U',
    log_fecha                      DATE NOT NULL,
    log_usuario                    VARCHAR2(255 BYTE),
    log_referencia                 VARCHAR2(500 BYTE) DEFAULT SYSDATE,
    log_tipo                       VARCHAR2(50 BYTE))
  NOPARALLEL
  LOGGING
/

ALTER TABLE digital_logs
ADD CONSTRAINT pk_logs_ar PRIMARY KEY (log_id)
USING INDEX
/

CREATE OR REPLACE TRIGGER trg_digital_logs_id
 BEFORE
  INSERT
 ON digital_logs
REFERENCING NEW AS NEW OLD AS OLD
 FOR EACH ROW
begin
if :NEW."LOG_ID" is null then
select "SEQ_TIM_LOGS".nextval into :NEW."LOG_ID" from dual;
end if;
end;
/

COMMENT ON TABLE digital_logs IS 'Tabla que almacena los logs del sistema'
/
COMMENT ON COLUMN digital_logs.log_app IS 'Nombre del sistema que registro el log'
/
COMMENT ON COLUMN digital_logs.log_fecha IS 'Fecha actual del sistema en la que se almaceno el registro'
/
COMMENT ON COLUMN digital_logs.log_id IS 'Numero auto incremental que identifica un registro'
/
COMMENT ON COLUMN digital_logs.log_ip IS 'Almacena el ip de la maquina que realiza la peticion'
/
COMMENT ON COLUMN digital_logs.log_mensaje IS 'Mensajes de error devueltos'
/
COMMENT ON COLUMN digital_logs.log_nivel IS 'Niveles de error'
/
COMMENT ON COLUMN digital_logs.log_referencia IS 'Amacena el nombre de la clase donde se genero el mensaje de log y el numero de linea donde si hizo la peticion para el evento de log'
/
COMMENT ON COLUMN digital_logs.log_tipo IS 'Ejm: Base de datos, Login, WS, Red'
/
COMMENT ON COLUMN digital_logs.log_usuario IS 'Usuario que opera el sistema o realiza la transaccion'
/
CREATE TABLE existej
    (cns_tipodoc1                   VARCHAR2(3 BYTE) NOT NULL,
    cns_adutra1                    VARCHAR2(3 BYTE) NOT NULL,
    cns_anio                       VARCHAR2(4 BYTE),
    cns_nrotra1                    VARCHAR2(50 BYTE) NOT NULL,
    tipodoc                        VARCHAR2(3 BYTE),
    cuo                            VARCHAR2(3 BYTE),
    anio                           VARCHAR2(4 BYTE),
    fanio                          VARCHAR2(4 BYTE),
    nrotra1                        VARCHAR2(255 BYTE),
    tif                            VARCHAR2(255 BYTE),
    estado                         CHAR(1 BYTE))
  NOPARALLEL
  LOGGING
/

CREATE TABLE existej1
    (cns_tipodoc1                   VARCHAR2(3 BYTE) NOT NULL,
    cns_adutra1                    VARCHAR2(3 BYTE) NOT NULL,
    cns_anio                       VARCHAR2(4 BYTE),
    cns_nrotra1                    VARCHAR2(255 BYTE),
    tipodoc                        VARCHAR2(3 BYTE),
    cuo                            VARCHAR2(3 BYTE),
    anio                           VARCHAR2(4 BYTE),
    fanio                          VARCHAR2(4 BYTE),
    nrotra1                        VARCHAR2(255 BYTE),
    tif                            VARCHAR2(255 BYTE),
    estado                         CHAR(1 BYTE))
  NOPARALLEL
  LOGGING
/

CREATE TABLE existej1_10
    (cns_tipodoc1                   VARCHAR2(3 BYTE) NOT NULL,
    cns_adutra1                    VARCHAR2(3 BYTE) NOT NULL,
    cns_anio                       VARCHAR2(4 BYTE),
    cns_nrotra1                    VARCHAR2(255 BYTE),
    tipodoc                        VARCHAR2(3 BYTE),
    cuo                            VARCHAR2(3 BYTE),
    anio                           VARCHAR2(4 BYTE),
    fanio                          VARCHAR2(4 BYTE),
    nrotra1                        VARCHAR2(255 BYTE),
    tif                            VARCHAR2(255 BYTE),
    estado                         CHAR(1 BYTE))
  NOPARALLEL
  LOGGING
/

CREATE TABLE existej1_9
    (cns_tipodoc1                   VARCHAR2(3 BYTE) NOT NULL,
    cns_adutra1                    VARCHAR2(3 BYTE) NOT NULL,
    cns_anio                       VARCHAR2(4 BYTE),
    cns_nrotra1                    VARCHAR2(255 BYTE),
    tipodoc                        VARCHAR2(3 BYTE),
    cuo                            VARCHAR2(3 BYTE),
    anio                           VARCHAR2(4 BYTE),
    fanio                          VARCHAR2(4 BYTE),
    nrotra1                        VARCHAR2(255 BYTE),
    tif                            VARCHAR2(255 BYTE),
    estado                         CHAR(1 BYTE))
  NOPARALLEL
  LOGGING
/

CREATE TABLE general
    (cns_codconc                    VARCHAR2(15 BYTE) NOT NULL,
    cns_tipodoc                    VARCHAR2(3 BYTE) NOT NULL,
    cns_emisor                     VARCHAR2(35 BYTE) NOT NULL,
    cns_nomarch                    VARCHAR2(50 BYTE) NOT NULL,
    cns_adutra                     VARCHAR2(3 BYTE) NOT NULL,
    cns_nrotra                     VARCHAR2(50 BYTE) NOT NULL,
    cns_fecha_emi                  DATE NOT NULL,
    cns_fecha_pro                  DATE NOT NULL,
    cns_estado                     CHAR(1 BYTE) NOT NULL,
    cns_usuario                    VARCHAR2(15 BYTE) NOT NULL,
    cns_fechasys                   DATE NOT NULL)
  PARALLEL (DEGREE DEFAULT)
  LOGGING
/

CREATE INDEX general_duiidx ON general
  (
    cns_nrotra                      ASC
  )
NOPARALLEL
LOGGING
/

CREATE INDEX idx_nomarch ON general
  (
    cns_nomarch                     ASC,
    cns_nrotra                      ASC
  )
NOPARALLEL
LOGGING
/


ALTER TABLE general
ADD CONSTRAINT pk_general PRIMARY KEY (cns_tipodoc, cns_emisor, cns_adutra, 
  cns_nrotra, cns_estado)
USING INDEX
/

COMMENT ON COLUMN general.cns_adutra IS 'Codigo de Aduana de tramite'
/
COMMENT ON COLUMN general.cns_codconc IS 'NIT del concesionario'
/
COMMENT ON COLUMN general.cns_emisor IS 'NIT del emisor del documento'
/
COMMENT ON COLUMN general.cns_estado IS 'Estado del envio del documento'
/
COMMENT ON COLUMN general.cns_fecha_emi IS 'Fecha de emision del numero de tramite'
/
COMMENT ON COLUMN general.cns_fecha_pro IS 'Fecha de proceso del documento digitalizado'
/
COMMENT ON COLUMN general.cns_fechasys IS 'Fecha del sistema'
/
COMMENT ON COLUMN general.cns_nomarch IS 'Nombre de archivo digitalizado'
/
COMMENT ON COLUMN general.cns_nrotra IS 'Numero de tramite'
/
COMMENT ON COLUMN general.cns_tipodoc IS 'Codigo tipo documento'
/
COMMENT ON COLUMN general.cns_usuario IS 'Nombre usuario proceso'
/
CREATE TABLE general_otro
    (cns_codconc                    VARCHAR2(15 BYTE) NOT NULL,
    cns_tipodoc                    VARCHAR2(3 BYTE) NOT NULL,
    cns_emisor                     VARCHAR2(35 BYTE) NOT NULL,
    cns_nomarch                    VARCHAR2(50 BYTE) NOT NULL,
    cns_adutra                     VARCHAR2(3 BYTE) NOT NULL,
    cns_nrotra                     VARCHAR2(50 BYTE) NOT NULL,
    cns_fecha_emi                  DATE NOT NULL,
    cns_fecha_pro                  DATE NOT NULL,
    cns_estado                     CHAR(1 BYTE) NOT NULL)
  PARALLEL (DEGREE DEFAULT)
  LOGGING
/

CREATE INDEX idx_nomarch1 ON general_otro
  (
    cns_nomarch                     ASC,
    cns_nrotra                      ASC
  )
NOPARALLEL
LOGGING
/


COMMENT ON COLUMN general_otro.cns_adutra IS 'Codigo de Aduana de tramite'
/
COMMENT ON COLUMN general_otro.cns_codconc IS 'NIT del concesionario'
/
COMMENT ON COLUMN general_otro.cns_emisor IS 'NIT del emisor del documento'
/
COMMENT ON COLUMN general_otro.cns_estado IS 'Estado del envio del documento'
/
COMMENT ON COLUMN general_otro.cns_fecha_emi IS 'Fecha de emision del numero de tramite'
/
COMMENT ON COLUMN general_otro.cns_fecha_pro IS 'Fecha de proceso del documento digitalizado'
/
COMMENT ON COLUMN general_otro.cns_nomarch IS 'Nombre de archivo digitalizado'
/
COMMENT ON COLUMN general_otro.cns_nrotra IS 'Numero de tramite'
/
COMMENT ON COLUMN general_otro.cns_tipodoc IS 'Codigo tipo documento'
/
CREATE TABLE general_otro1
    (cns_codconc                    VARCHAR2(15 BYTE) NOT NULL,
    cns_tipodoc                    VARCHAR2(3 BYTE) NOT NULL,
    cns_emisor                     VARCHAR2(35 BYTE) NOT NULL,
    cns_nomarch                    VARCHAR2(50 BYTE) NOT NULL,
    cns_adutra                     VARCHAR2(3 BYTE) NOT NULL,
    cns_nrotra                     VARCHAR2(50 BYTE) NOT NULL,
    cns_fecha_emi                  DATE NOT NULL,
    cns_fecha_pro                  DATE NOT NULL,
    cns_estado                     CHAR(1 BYTE) NOT NULL)
  NOPARALLEL
  LOGGING
/

CREATE INDEX idx_nomarch2 ON general_otro1
  (
    cns_nomarch                     ASC,
    cns_nrotra                      ASC
  )
NOPARALLEL
LOGGING
/

CREATE INDEX idx_general ON general_otro1
  (
    cns_tipodoc                     ASC,
    cns_nrotra                      ASC
  )
NOPARALLEL
LOGGING
/


CREATE TABLE general_otro2
    (cns_codconc                    VARCHAR2(15 BYTE) NOT NULL,
    cns_tipodoc                    VARCHAR2(3 BYTE) NOT NULL,
    cns_emisor                     VARCHAR2(35 BYTE) NOT NULL,
    cns_nomarch                    VARCHAR2(50 BYTE) NOT NULL,
    cns_adutra                     VARCHAR2(3 BYTE) NOT NULL,
    cns_nrotra                     VARCHAR2(50 BYTE) NOT NULL,
    cns_fecha_emi                  DATE NOT NULL,
    cns_fecha_pro                  DATE NOT NULL,
    cns_estado                     CHAR(1 BYTE) NOT NULL)
  NOPARALLEL
  LOGGING
/

CREATE INDEX ".IDX_NOMARCH3" ON general_otro2
  (
    cns_nomarch                     ASC,
    cns_nrotra                      ASC
  )
NOPARALLEL
LOGGING
/


CREATE TABLE generalprbxmltype
    (genera                         SYS.XMLTYPE)
  NOPARALLEL
  LOGGING
/

CREATE TABLE j1
    (cns_tipodoc1                   VARCHAR2(3 BYTE) NOT NULL,
    pr                             VARCHAR2(3 BYTE),
    cns_nrotra1                    VARCHAR2(50 BYTE) NOT NULL,
    parecido                       VARCHAR2(255 BYTE),
    estado                         CHAR(1 BYTE))
  NOPARALLEL
  LOGGING
/

CREATE TABLE ne2010_4
    (cns_tipodoc1                   VARCHAR2(3 BYTE) NOT NULL,
    cns_adutra1                    VARCHAR2(3 BYTE) NOT NULL,
    cns_anio                       VARCHAR2(4 BYTE),
    fanio                          VARCHAR2(4 BYTE),
    cns_nrotra1                    VARCHAR2(50 BYTE) NOT NULL)
  NOPARALLEL
  LOGGING
/

CREATE TABLE ne2010_41
    (cns_tipodoc1                   VARCHAR2(3 BYTE) NOT NULL,
    cns_adutra1                    VARCHAR2(3 BYTE) NOT NULL,
    cns_anio                       VARCHAR2(4 BYTE),
    fanio                          VARCHAR2(4 BYTE),
    cns_nrotra1                    VARCHAR2(255 BYTE))
  NOPARALLEL
  LOGGING
/

CREATE TABLE ne2010_419
    (cns_tipodoc1                   VARCHAR2(3 BYTE) NOT NULL,
    cns_adutra1                    VARCHAR2(3 BYTE) NOT NULL,
    cns_anio                       VARCHAR2(4 BYTE),
    fanio                          VARCHAR2(4 BYTE),
    cns_nrotra1                    VARCHAR2(255 BYTE))
  NOPARALLEL
  LOGGING
/

CREATE TABLE no_encontrados
    (cns_tipodoc1                   VARCHAR2(3 BYTE) NOT NULL,
    cns_adutra1                    VARCHAR2(3 BYTE) NOT NULL,
    cns_nrotra1                    VARCHAR2(255 BYTE),
    cns_emisor1                    VARCHAR2(35 BYTE) NOT NULL,
    cns_fechaemi1                  DATE NOT NULL,
    cns_tipodoc2                   VARCHAR2(3 BYTE) NOT NULL,
    cns_adutra2                    VARCHAR2(3 BYTE) NOT NULL,
    cns_nrotra2                    VARCHAR2(50 BYTE) NOT NULL,
    cns_emisor2                    VARCHAR2(35 BYTE) NOT NULL,
    cns_fechaemi2                  DATE NOT NULL,
    cns_estado                     CHAR(1 BYTE) NOT NULL)
  NOPARALLEL
  LOGGING
/

CREATE TABLE nomarch
    (nombre                         VARCHAR2(50 BYTE) NOT NULL,
    longitud                       NUMBER NOT NULL)
  PARALLEL (DEGREE DEFAULT)
  LOGGING
/

COMMENT ON COLUMN nomarch.longitud IS 'Tamaño archivo en bytes'
/
COMMENT ON COLUMN nomarch.nombre IS 'Nombre archivo tif'
/
CREATE TABLE observacion
    (cns_codconc                    VARCHAR2(15 BYTE) NOT NULL,
    cns_perproc                    VARCHAR2(6 BYTE) NOT NULL,
    cns_observacion                VARCHAR2(3500 BYTE) NOT NULL,
    cns_version                    NUMBER DEFAULT 0 NOT NULL,
    cns_usuario                    VARCHAR2(15 BYTE) NOT NULL,
    cns_fechasys                   DATE NOT NULL,
    cns_codope                     NUMBER NOT NULL,
    cns_estope                     NUMBER NOT NULL)
  PARALLEL (DEGREE DEFAULT)
  LOGGING
/

COMMENT ON COLUMN observacion.cns_codconc IS 'NIT del concesionario'
/
COMMENT ON COLUMN observacion.cns_codope IS 'Codigo de operacion'
/
COMMENT ON COLUMN observacion.cns_estope IS 'Estado de operacion'
/
COMMENT ON COLUMN observacion.cns_fechasys IS 'Fecha del sistema'
/
COMMENT ON COLUMN observacion.cns_observacion IS 'Observacion de proceso'
/
COMMENT ON COLUMN observacion.cns_perproc IS 'Periodo de proceso (mmaaaa)'
/
COMMENT ON COLUMN observacion.cns_usuario IS 'Nombre usuario proceso'
/
COMMENT ON COLUMN observacion.cns_version IS 'Version de proceso'
/
CREATE TABLE relacion
    (cns_tipodoc1                   VARCHAR2(3 BYTE) NOT NULL,
    cns_adutra1                    VARCHAR2(3 BYTE) NOT NULL,
    cns_nrotra1                    VARCHAR2(50 BYTE) NOT NULL,
    cns_emisor1                    VARCHAR2(35 BYTE) NOT NULL,
    cns_fechaemi1                  DATE NOT NULL,
    cns_tipodoc2                   VARCHAR2(3 BYTE) NOT NULL,
    cns_adutra2                    VARCHAR2(3 BYTE) NOT NULL,
    cns_nrotra2                    VARCHAR2(50 BYTE) NOT NULL,
    cns_emisor2                    VARCHAR2(35 BYTE) NOT NULL,
    cns_fechaemi2                  DATE NOT NULL,
    cns_estado                     CHAR(1 BYTE) NOT NULL,
    cns_usuario                    VARCHAR2(15 BYTE) NOT NULL,
    cns_fechasys                   DATE NOT NULL)
  PARALLEL (DEGREE DEFAULT)
  LOGGING
/

ALTER TABLE relacion
ADD CONSTRAINT pk_relacion PRIMARY KEY (cns_tipodoc1, cns_adutra1, cns_nrotra1, 
  cns_emisor1, cns_tipodoc2, cns_adutra2, cns_nrotra2, cns_emisor2, cns_estado)
USING INDEX
/

COMMENT ON COLUMN relacion.cns_adutra1 IS 'Codigo Aduana de tramite'
/
COMMENT ON COLUMN relacion.cns_adutra2 IS 'Codigo Aduana de tramite'
/
COMMENT ON COLUMN relacion.cns_emisor1 IS 'NIT emisor documento'
/
COMMENT ON COLUMN relacion.cns_emisor2 IS 'NIT emisor documento'
/
COMMENT ON COLUMN relacion.cns_estado IS 'Estado envio documento'
/
COMMENT ON COLUMN relacion.cns_fechaemi1 IS 'Fecha emision documento'
/
COMMENT ON COLUMN relacion.cns_fechaemi2 IS 'Fecha emision documento'
/
COMMENT ON COLUMN relacion.cns_fechasys IS 'Fecha del sistema'
/
COMMENT ON COLUMN relacion.cns_nrotra1 IS 'Numero tramite'
/
COMMENT ON COLUMN relacion.cns_nrotra2 IS 'Numero tramite'
/
COMMENT ON COLUMN relacion.cns_tipodoc1 IS 'Codigo tipo documento'
/
COMMENT ON COLUMN relacion.cns_tipodoc2 IS 'Codigo tipo documento'
/
COMMENT ON COLUMN relacion.cns_usuario IS 'Nombre usuario proceso'
/
CREATE TABLE relacion_otro
    (cns_tipodoc1                   VARCHAR2(3 BYTE) NOT NULL,
    cns_adutra1                    VARCHAR2(3 BYTE) NOT NULL,
    cns_nrotra1                    VARCHAR2(50 BYTE) NOT NULL,
    cns_emisor1                    VARCHAR2(35 BYTE) NOT NULL,
    cns_fechaemi1                  DATE NOT NULL,
    cns_tipodoc2                   VARCHAR2(3 BYTE) NOT NULL,
    cns_adutra2                    VARCHAR2(3 BYTE) NOT NULL,
    cns_nrotra2                    VARCHAR2(50 BYTE) NOT NULL,
    cns_emisor2                    VARCHAR2(35 BYTE) NOT NULL,
    cns_fechaemi2                  DATE NOT NULL,
    cns_estado                     CHAR(1 BYTE) NOT NULL)
  PARALLEL (DEGREE DEFAULT)
  LOGGING
/

CREATE INDEX idx_nrotra ON relacion_otro
  (
    cns_nrotra1                     ASC,
    cns_nrotra2                     ASC
  )
NOPARALLEL
LOGGING
/


CREATE TABLE relacion_otro1
    (cns_tipodoc1                   VARCHAR2(3 BYTE) NOT NULL,
    cns_adutra1                    VARCHAR2(3 BYTE) NOT NULL,
    cns_nrotra1                    VARCHAR2(50 BYTE) NOT NULL,
    cns_emisor1                    VARCHAR2(35 BYTE) NOT NULL,
    cns_fechaemi1                  DATE NOT NULL,
    cns_tipodoc2                   VARCHAR2(3 BYTE) NOT NULL,
    cns_adutra2                    VARCHAR2(3 BYTE) NOT NULL,
    cns_nrotra2                    VARCHAR2(50 BYTE) NOT NULL,
    cns_emisor2                    VARCHAR2(35 BYTE) NOT NULL,
    cns_fechaemi2                  DATE NOT NULL,
    cns_estado                     CHAR(1 BYTE) NOT NULL)
  NOPARALLEL
  LOGGING
/

CREATE INDEX idx_nrotra1 ON relacion_otro1
  (
    cns_nrotra1                     ASC,
    cns_nrotra2                     ASC
  )
NOPARALLEL
LOGGING
/


CREATE TABLE relacion_otro2
    (cns_tipodoc1                   VARCHAR2(3 BYTE) NOT NULL,
    cns_adutra1                    VARCHAR2(3 BYTE) NOT NULL,
    cns_nrotra1                    VARCHAR2(50 BYTE) NOT NULL,
    cns_emisor1                    VARCHAR2(35 BYTE) NOT NULL,
    cns_fechaemi1                  DATE NOT NULL,
    cns_tipodoc2                   VARCHAR2(3 BYTE) NOT NULL,
    cns_adutra2                    VARCHAR2(3 BYTE) NOT NULL,
    cns_nrotra2                    VARCHAR2(50 BYTE) NOT NULL,
    cns_emisor2                    VARCHAR2(35 BYTE) NOT NULL,
    cns_fechaemi2                  DATE NOT NULL,
    cns_estado                     CHAR(1 BYTE) NOT NULL)
  NOPARALLEL
  LOGGING
/

CREATE INDEX idx_nrotra2 ON relacion_otro2
  (
    cns_nrotra1                     ASC,
    cns_nrotra2                     ASC
  )
NOPARALLEL
LOGGING
/


CREATE TABLE relacion_otroj
    (cns_tipodoc1                   VARCHAR2(3 BYTE) NOT NULL,
    cns_adutra1                    VARCHAR2(3 BYTE) NOT NULL,
    cns_nrotra1                    VARCHAR2(50 BYTE) NOT NULL,
    cns_emisor1                    VARCHAR2(35 BYTE) NOT NULL,
    cns_fechaemi1                  DATE NOT NULL,
    cns_tipodoc2                   VARCHAR2(3 BYTE) NOT NULL,
    cns_adutra2                    VARCHAR2(3 BYTE) NOT NULL,
    cns_nrotra2                    VARCHAR2(50 BYTE) NOT NULL,
    cns_emisor2                    VARCHAR2(35 BYTE) NOT NULL,
    cns_fechaemi2                  DATE NOT NULL,
    cns_estado                     CHAR(1 BYTE) NOT NULL)
  NOPARALLEL
  LOGGING
/

CREATE INDEX idx_nrotra3 ON relacion_otroj
  (
    cns_nrotra1                     ASC,
    cns_nrotra2                     ASC
  )
NOPARALLEL
LOGGING
/


CREATE TABLE relacion_otroj1
    (cns_tipodoc1                   VARCHAR2(3 BYTE) NOT NULL,
    cns_adutra1                    VARCHAR2(3 BYTE) NOT NULL,
    cns_nrotra1                    VARCHAR2(255 BYTE),
    cns_emisor1                    VARCHAR2(35 BYTE) NOT NULL,
    cns_fechaemi1                  DATE NOT NULL,
    cns_tipodoc2                   VARCHAR2(3 BYTE) NOT NULL,
    cns_adutra2                    VARCHAR2(3 BYTE) NOT NULL,
    cns_nrotra2                    VARCHAR2(50 BYTE) NOT NULL,
    cns_emisor2                    VARCHAR2(35 BYTE) NOT NULL,
    cns_fechaemi2                  DATE NOT NULL,
    cns_estado                     CHAR(1 BYTE) NOT NULL)
  NOPARALLEL
  LOGGING
/

CREATE INDEX idx_nrotraj1 ON relacion_otroj1
  (
    cns_nrotra1                     ASC
  )
NOPARALLEL
LOGGING
/


CREATE TABLE relacion_otroj1_9
    (cns_tipodoc1                   VARCHAR2(3 BYTE) NOT NULL,
    cns_adutra1                    VARCHAR2(3 BYTE) NOT NULL,
    cns_nrotra1                    VARCHAR2(255 BYTE),
    cns_emisor1                    VARCHAR2(35 BYTE) NOT NULL,
    cns_fechaemi1                  DATE NOT NULL,
    cns_tipodoc2                   VARCHAR2(3 BYTE) NOT NULL,
    cns_adutra2                    VARCHAR2(3 BYTE) NOT NULL,
    cns_nrotra2                    VARCHAR2(50 BYTE) NOT NULL,
    cns_emisor2                    VARCHAR2(35 BYTE) NOT NULL,
    cns_fechaemi2                  DATE NOT NULL,
    cns_estado                     CHAR(1 BYTE) NOT NULL)
  NOPARALLEL
  LOGGING
/

CREATE INDEX idx_ntra19 ON relacion_otroj1_9
  (
    cns_nrotra1                     ASC
  )
NOPARALLEL
LOGGING
/


CREATE TABLE t2007_1
    (tif                            VARCHAR2(255 BYTE))
  NOPARALLEL
  LOGGING
/

CREATE TABLE t2007_3
    (tif                            VARCHAR2(255 BYTE))
  NOPARALLEL
  LOGGING
/

CREATE TABLE t2010_1
    (tif                            VARCHAR2(255 BYTE))
  NOPARALLEL
  LOGGING
/

CREATE TABLE t2010_2
    (tif                            VARCHAR2(255 BYTE))
  NOPARALLEL
  LOGGING
/

CREATE TABLE t2010_3
    (tif                            VARCHAR2(255 BYTE))
  NOPARALLEL
  LOGGING
/

CREATE TABLE t2010_4
    (tif                            VARCHAR2(255 BYTE))
  NOPARALLEL
  LOGGING
/

CREATE TABLE t2010_41
    (tipodoc                        VARCHAR2(3 BYTE),
    cuo                            VARCHAR2(3 BYTE),
    anio                           VARCHAR2(4 BYTE),
    nrotra1                        VARCHAR2(255 BYTE),
    tif                            VARCHAR2(255 BYTE))
  NOPARALLEL
  LOGGING
/

CREATE INDEX idxt41 ON t2010_41
  (
    nrotra1                         ASC
  )
NOPARALLEL
LOGGING
/


CREATE TABLE tmp_01_04_2010
    (cns_tipodoc1                   VARCHAR2(3 BYTE) NOT NULL,
    cns_nrotra1                    VARCHAR2(50 BYTE) NOT NULL)
  NOPARALLEL
  LOGGING
/

CREATE TABLE tmp_general
    (cns_codconc                    VARCHAR2(15 BYTE) NOT NULL,
    cns_tipodoc                    VARCHAR2(3 BYTE) NOT NULL,
    cns_emisor                     VARCHAR2(35 BYTE) NOT NULL,
    cns_nomarch                    VARCHAR2(50 BYTE) NOT NULL,
    cns_adutra                     VARCHAR2(3 BYTE) NOT NULL,
    cns_nrotra                     VARCHAR2(50 BYTE) NOT NULL,
    cns_fecha_emi                  DATE NOT NULL,
    cns_fecha_pro                  DATE NOT NULL,
    cns_estado                     CHAR(1 BYTE) NOT NULL)
  PARALLEL (DEGREE DEFAULT)
  LOGGING
/

ALTER TABLE tmp_general
ADD CONSTRAINT pk_tmp_general PRIMARY KEY (cns_tipodoc, cns_emisor, cns_adutra, 
  cns_nrotra, cns_estado)
USING INDEX
/

ALTER TABLE tmp_general
ADD CHECK (CNS_CODCONC IS NOT NULL)
/

ALTER TABLE tmp_general
ADD CHECK (CNS_TIPODOC IS NOT NULL)
/

ALTER TABLE tmp_general
ADD CHECK (CNS_EMISOR IS NOT NULL)
/

ALTER TABLE tmp_general
ADD CHECK (CNS_NOMARCH IS NOT NULL)
/

ALTER TABLE tmp_general
ADD CHECK (CNS_ADUTRA IS NOT NULL)
/

ALTER TABLE tmp_general
ADD CHECK (CNS_NROTRA IS NOT NULL)
/

ALTER TABLE tmp_general
ADD CHECK (CNS_FECHA_EMI IS NOT NULL)
/

ALTER TABLE tmp_general
ADD CHECK (CNS_FECHA_PRO IS NOT NULL)
/

ALTER TABLE tmp_general
ADD CHECK (CNS_ESTADO IS NOT NULL)
/

COMMENT ON COLUMN tmp_general.cns_adutra IS 'Codigo de Aduana de tramite'
/
COMMENT ON COLUMN tmp_general.cns_codconc IS 'NIT del concesionario'
/
COMMENT ON COLUMN tmp_general.cns_emisor IS 'NIT del emisor del documento'
/
COMMENT ON COLUMN tmp_general.cns_estado IS 'Estado del envio del documento'
/
COMMENT ON COLUMN tmp_general.cns_fecha_emi IS 'Fecha de emision del numero de tramite'
/
COMMENT ON COLUMN tmp_general.cns_fecha_pro IS 'Fecha de proceso del documento digitalizado'
/
COMMENT ON COLUMN tmp_general.cns_nomarch IS 'Nombre de archivo digitalizado'
/
COMMENT ON COLUMN tmp_general.cns_nrotra IS 'Numero de tramite'
/
COMMENT ON COLUMN tmp_general.cns_tipodoc IS 'Codigo tipo documento'
/
CREATE TABLE tmp_general_aux
    (cns_codconc                    VARCHAR2(15 BYTE) NOT NULL,
    cns_tipodoc                    VARCHAR2(3 BYTE) NOT NULL,
    cns_emisor                     VARCHAR2(35 BYTE) NOT NULL,
    cns_nomarch                    VARCHAR2(50 BYTE) NOT NULL,
    cns_adutra                     VARCHAR2(3 BYTE) NOT NULL,
    cns_nrotra                     VARCHAR2(50 BYTE) NOT NULL,
    cns_fecha_emi                  DATE NOT NULL,
    cns_fecha_pro                  DATE NOT NULL,
    cns_estado                     CHAR(1 BYTE) NOT NULL)
  PARALLEL (DEGREE DEFAULT)
  LOGGING
/

COMMENT ON COLUMN tmp_general_aux.cns_adutra IS 'Codigo de Aduana de tramite'
/
COMMENT ON COLUMN tmp_general_aux.cns_codconc IS 'NIT del concesionario'
/
COMMENT ON COLUMN tmp_general_aux.cns_emisor IS 'NIT del emisor del documento'
/
COMMENT ON COLUMN tmp_general_aux.cns_estado IS 'Estado del envio del documento'
/
COMMENT ON COLUMN tmp_general_aux.cns_fecha_emi IS 'Fecha de emision del numero de tramite'
/
COMMENT ON COLUMN tmp_general_aux.cns_fecha_pro IS 'Fecha de proceso del documento digitalizado'
/
COMMENT ON COLUMN tmp_general_aux.cns_nomarch IS 'Nombre de archivo digitalizado'
/
COMMENT ON COLUMN tmp_general_aux.cns_nrotra IS 'Numero de tramite'
/
COMMENT ON COLUMN tmp_general_aux.cns_tipodoc IS 'Codigo tipo documento'
/
CREATE TABLE tmp_relacion
    (cns_tipodoc1                   VARCHAR2(3 BYTE) NOT NULL,
    cns_adutra1                    VARCHAR2(3 BYTE) NOT NULL,
    cns_nrotra1                    VARCHAR2(50 BYTE) NOT NULL,
    cns_emisor1                    VARCHAR2(35 BYTE) NOT NULL,
    cns_fechaemi1                  DATE NOT NULL,
    cns_tipodoc2                   VARCHAR2(3 BYTE) NOT NULL,
    cns_adutra2                    VARCHAR2(3 BYTE) NOT NULL,
    cns_nrotra2                    VARCHAR2(50 BYTE) NOT NULL,
    cns_emisor2                    VARCHAR2(35 BYTE) NOT NULL,
    cns_fechaemi2                  DATE NOT NULL,
    cns_estado                     CHAR(1 BYTE) NOT NULL)
  PARALLEL (DEGREE DEFAULT)
  LOGGING
/

COMMENT ON COLUMN tmp_relacion.cns_adutra1 IS 'Codigo Aduana de tramite'
/
COMMENT ON COLUMN tmp_relacion.cns_adutra2 IS 'Codigo Aduana de tramite'
/
COMMENT ON COLUMN tmp_relacion.cns_emisor1 IS 'NIT emisor documento'
/
COMMENT ON COLUMN tmp_relacion.cns_emisor2 IS 'NIT emisor documento'
/
COMMENT ON COLUMN tmp_relacion.cns_estado IS 'Estado envio documento'
/
COMMENT ON COLUMN tmp_relacion.cns_fechaemi1 IS 'Fecha emision documento'
/
COMMENT ON COLUMN tmp_relacion.cns_fechaemi2 IS 'Fecha emision documento'
/
COMMENT ON COLUMN tmp_relacion.cns_nrotra1 IS 'Numero tramite'
/
COMMENT ON COLUMN tmp_relacion.cns_nrotra2 IS 'Numero tramite'
/
COMMENT ON COLUMN tmp_relacion.cns_tipodoc1 IS 'Codigo tipo documento'
/
COMMENT ON COLUMN tmp_relacion.cns_tipodoc2 IS 'Codigo tipo documento'
/
CREATE TABLE tmp_relacion_aux
    (cns_tipodoc1                   VARCHAR2(3 BYTE) NOT NULL,
    cns_adutra1                    VARCHAR2(3 BYTE) NOT NULL,
    cns_nrotra1                    VARCHAR2(50 BYTE) NOT NULL,
    cns_emisor1                    VARCHAR2(35 BYTE) NOT NULL,
    cns_fechaemi1                  DATE NOT NULL,
    cns_tipodoc2                   VARCHAR2(3 BYTE) NOT NULL,
    cns_adutra2                    VARCHAR2(3 BYTE) NOT NULL,
    cns_nrotra2                    VARCHAR2(50 BYTE) NOT NULL,
    cns_emisor2                    VARCHAR2(35 BYTE) NOT NULL,
    cns_fechaemi2                  DATE NOT NULL,
    cns_estado                     CHAR(1 BYTE) NOT NULL)
  PARALLEL (DEGREE DEFAULT)
  LOGGING
/

CREATE TABLE tmp_total
    (cns_codcon                     VARCHAR2(15 BYTE) NOT NULL,
    cns_tipdoc                     VARCHAR2(3 BYTE) NOT NULL,
    cns_fecenv                     DATE NOT NULL,
    cns_estado                     CHAR(1 BYTE) NOT NULL,
    cns_cantidad                   NUMBER(6,0) NOT NULL)
  PARALLEL (DEGREE DEFAULT)
  LOGGING
/

ALTER TABLE tmp_total
ADD CONSTRAINT pk_tmp_total PRIMARY KEY (cns_codcon, cns_tipdoc, cns_fecenv, 
  cns_estado)
USING INDEX
/

COMMENT ON COLUMN tmp_total.cns_cantidad IS 'Cantidad documentos por tipo'
/
COMMENT ON COLUMN tmp_total.cns_codcon IS 'NIT concesionario'
/
COMMENT ON COLUMN tmp_total.cns_estado IS 'Estado envio documento'
/
COMMENT ON COLUMN tmp_total.cns_fecenv IS 'Fecha envio documento'
/
COMMENT ON COLUMN tmp_total.cns_tipdoc IS 'Codigo tipo documento'
/
CREATE TABLE tmp410
    (cns_nomarch                    VARCHAR2(50 BYTE) NOT NULL)
  NOPARALLEL
  LOGGING
/

CREATE TABLE total
    (cns_codcon                     VARCHAR2(15 BYTE) NOT NULL,
    cns_tipdoc                     VARCHAR2(3 BYTE) NOT NULL,
    cns_fecenv                     DATE NOT NULL,
    cns_estado                     CHAR(1 BYTE) NOT NULL,
    cns_cantidad                   NUMBER(6,0) NOT NULL,
    cns_usuario                    VARCHAR2(15 BYTE) NOT NULL,
    cns_fechasys                   DATE NOT NULL)
  PARALLEL (DEGREE DEFAULT)
  LOGGING
/

ALTER TABLE total
ADD CONSTRAINT pk_total PRIMARY KEY (cns_codcon, cns_tipdoc, cns_fecenv, 
  cns_estado)
USING INDEX
/

COMMENT ON COLUMN total.cns_cantidad IS 'Cantidad documentos por tipo'
/
COMMENT ON COLUMN total.cns_codcon IS 'NIT concesionario'
/
COMMENT ON COLUMN total.cns_estado IS 'Estado envio documento'
/
COMMENT ON COLUMN total.cns_fecenv IS 'Fecha envio documento'
/
COMMENT ON COLUMN total.cns_fechasys IS 'Fecha del sistema'
/
COMMENT ON COLUMN total.cns_tipdoc IS 'Codigo tipo documento'
/
COMMENT ON COLUMN total.cns_usuario IS 'Nombre usuario proceso'
/
CREATE TABLE total_otro
    (cns_codcon                     VARCHAR2(15 BYTE) NOT NULL,
    cns_tipdoc                     VARCHAR2(3 BYTE) NOT NULL,
    cns_fecenv                     DATE NOT NULL,
    cns_estado                     CHAR(1 BYTE) NOT NULL,
    cns_cantidad                   NUMBER(6,0) NOT NULL)
  PARALLEL (DEGREE DEFAULT)
  LOGGING
/

COMMENT ON COLUMN total_otro.cns_cantidad IS 'Cantidad documentos por tipo'
/
COMMENT ON COLUMN total_otro.cns_codcon IS 'NIT concesionario'
/
COMMENT ON COLUMN total_otro.cns_estado IS 'Estado envio documento'
/
COMMENT ON COLUMN total_otro.cns_fecenv IS 'Fecha envio documento'
/
COMMENT ON COLUMN total_otro.cns_tipdoc IS 'Codigo tipo documento'
/
CREATE TABLE untipdoc
    (key_tip                        VARCHAR2(3 BYTE) NOT NULL,
    dsc_tip                        VARCHAR2(80 BYTE) NOT NULL,
    lst_ope                        VARCHAR2(1 BYTE) NOT NULL,
    nit_emi                        CHAR(1 BYTE) DEFAULT 0 NOT NULL)
  PARALLEL (DEGREE DEFAULT)
  LOGGING
/

CREATE UNIQUE INDEX untipdoc_idx ON untipdoc
  (
    key_tip                         ASC,
    lst_ope                         ASC
  )
NOPARALLEL
LOGGING
/


COMMENT ON COLUMN untipdoc.dsc_tip IS 'Descripcion Tipo Documento'
/
COMMENT ON COLUMN untipdoc.key_tip IS 'Codigo Tipo Documento'
/
COMMENT ON COLUMN untipdoc.lst_ope IS 'Estado Tipo Documento'
/
COMMENT ON COLUMN untipdoc.nit_emi IS 'Flag NIT Emisor'
/
CREATE TABLE untipope
    (cns_codope                     NUMBER NOT NULL,
    cns_desope                     VARCHAR2(35 BYTE) NOT NULL,
    lst_ope                        VARCHAR2(1 BYTE) NOT NULL)
  PARALLEL (DEGREE DEFAULT)
  LOGGING
/

COMMENT ON COLUMN untipope.cns_codope IS 'Codigo de operacion'
/
COMMENT ON COLUMN untipope.cns_desope IS 'Descripcion de operacion'
/
COMMENT ON COLUMN untipope.lst_ope IS 'Estado de operacion'
/
CREATE TABLE untiprel
    (key_tip_ori                    VARCHAR2(3 BYTE) NOT NULL,
    key_tip_gen                    VARCHAR2(3 BYTE) NOT NULL,
    lst_ope                        VARCHAR2(1 BYTE) NOT NULL)
  PARALLEL (DEGREE DEFAULT)
  LOGGING
/

COMMENT ON COLUMN untiprel.key_tip_gen IS 'Codigo Tipo Documento Generado'
/
COMMENT ON COLUMN untiprel.key_tip_ori IS 'Codigo Tipo Documento Origen'
/
COMMENT ON COLUMN untiprel.lst_ope IS 'Estado relacion documento'
/
