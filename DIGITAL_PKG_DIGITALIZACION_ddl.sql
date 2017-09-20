CREATE OR REPLACE 
PACKAGE pkg_digitalizacion
/* Formatted on 11-sep.-2017 10:58:04 (QP5 v5.126) */
IS
    -- RECURSIVIDAD

    FUNCTION recorrido2nivel1 (prm_tramite         IN     VARCHAR2,
                               prm_tipodocumento   IN     VARCHAR2,
                               prm_nodos              OUT VARCHAR2,
                               prm_tabla           IN     VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE relaciones (prm_tramite         IN     VARCHAR2,
                          prm_tipodocumento   IN     VARCHAR2,
                          c_resultado            OUT sys_refcursor);

    -- DEVUELVE PARAMETRICAS

    PROCEDURE obtener_tipo_doc (prm_lstope    IN     VARCHAR2,
                                prm_nit_emi   IN     VARCHAR2,
                                c_tipo_doc       OUT sys_refcursor);

    PROCEDURE obtener_aduanas_activas (c_aduanas OUT sys_refcursor);

    -- CONSULTAS DEL SISTEMA

    PROCEDURE consulta_por_filtro2 (
        prm_codconsignatario   IN     VARCHAR2,
        prm_tipodocumento      IN     VARCHAR2,
        prm_emisor             IN     VARCHAR2,
        prm_aduana             IN     VARCHAR2,
        prm_fechaemision_ini   IN     VARCHAR2,
        prm_fechaemision_fin   IN     VARCHAR2,
        prm_tabla              IN     VARCHAR2,
        prm_tipofecha          IN     VARCHAR2,
        c_resultado               OUT sys_refcursor);

    PROCEDURE consulta_por_tramite2 (prm_tramite   IN     VARCHAR2,
                                     prm_tabla     IN     VARCHAR2,
                                     c_resultado      OUT sys_refcursor);

    FUNCTION ceros (numero IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION PATH (fecha IN DATE)
        RETURN VARCHAR2;

    FUNCTION pathweb (fecha IN DATE)
        RETURN VARCHAR2;
END;
/

CREATE OR REPLACE 
PACKAGE BODY pkg_digitalizacion
/* Formatted on 20/09/2017 17:48:34 (QP5 v5.126) */
IS
    PROCEDURE relaciones (prm_tramite         IN     VARCHAR2,
                          prm_tipodocumento   IN     VARCHAR2,
                          c_resultado            OUT sys_refcursor)
    IS
        cont   NUMBER;
    BEGIN
        OPEN c_resultado FOR
            SELECT   c.cns_codconc,
                     a.cns_adutra2 || ':' || u.cuo_nam cns_adutra,
                     a.cns_nrotra2 cns_nrotra,
                     a.cns_tipodoc2 cns_tipodoc,
                     a.cns_tipodoc2 || ':' || t.dsc_tip dsc_tip,
                     a.cns_emisor2 cns_emisor,
                     DECODE (
                         c.cns_nomarch,
                         NULL,
                         '',
                         pkg_digitalizacion.pathweb (c.cns_fecha_pro)
                         || c.cns_nomarch)
                         PATH,
                     DECODE (c.cns_nomarch,
                             NULL, 'NO DIGITALIZADO',
                             c.cns_nomarch)
                         cns_nomarch,
                     TO_CHAR (a.cns_fechaemi2, 'dd/mm/yyyy') cns_fecha_emi,
                     TO_CHAR (c.cns_fecha_pro, 'dd/mm/yyyy') cns_fecha_pro,
                     c.cns_estado,
                     '-' cns_usuario,
                     TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi') cns_fechasys
              FROM   digital.relacion_otro2 a,
                     digital.general_otro1 b,
                     digital.general_otro1 c,
                     untipdoc t,
                     ops$asy.uncuotab@basy.sidunealin u
             WHERE       a.cns_tipodoc2 = t.key_tip
                     AND a.cns_adutra2 = u.cuo_cod(+)
                     AND u.lst_ope(+) = 'U'
                     AND t.lst_ope = 'U'
                     AND a.cns_nrotra1 || '-' || a.cns_tipodoc1 <>
                            a.cns_nrotra2 || '-' || a.cns_tipodoc2
                     AND a.cns_tipodoc1 = b.cns_tipodoc
                     AND a.cns_adutra1 = b.cns_adutra
                     AND a.cns_nrotra1 = b.cns_nrotra
                     AND a.cns_emisor1 = b.cns_emisor
                     AND a.cns_fechaemi1 = b.cns_fecha_emi
                     AND b.cns_nomarch =
                            prm_tramite || '-' || prm_tipodocumento || '.tif'
                     AND a.cns_tipodoc2 = c.cns_tipodoc(+)
                     AND a.cns_adutra2 = c.cns_adutra(+)
                     AND a.cns_nrotra2 = c.cns_nrotra(+)
                     AND a.cns_emisor2 = c.cns_emisor(+)
                     AND a.cns_fechaemi2 = c.cns_fecha_emi(+)
            UNION ALL
            SELECT   c.cns_codconc,
                     a.cns_adutra1 || ':' || u.cuo_nam cns_adutra,
                     a.cns_nrotra1 cns_nrotra,
                     a.cns_tipodoc1 cns_tipodoc,
                     a.cns_tipodoc1 || ':' || t.dsc_tip dsc_tip,
                     a.cns_emisor1 cns_emisor,
                     DECODE (
                         c.cns_nomarch,
                         NULL,
                         '',
                         pkg_digitalizacion.pathweb (c.cns_fecha_pro)
                         || c.cns_nomarch)
                         PATH,
                     DECODE (c.cns_nomarch,
                             NULL, 'NO DIGITALIZADO',
                             c.cns_nomarch)
                         cns_nomarch,
                     TO_CHAR (a.cns_fechaemi1, 'dd/mm/yyyy') cns_fecha_emi,
                     TO_CHAR (c.cns_fecha_pro, 'dd/mm/yyyy') cns_fecha_pro,
                     c.cns_estado,
                     '-' cns_usuario,
                     TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi') cns_fechasys
              FROM   digital.relacion_otro2 a,
                     digital.general_otro1 b,
                     digital.general_otro1 c,
                     untipdoc t,
                     ops$asy.uncuotab@basy.sidunealin u
             WHERE       a.cns_tipodoc1 = t.key_tip
                     AND a.cns_adutra1 = u.cuo_cod(+)
                     AND u.lst_ope(+) = 'U'
                     AND t.lst_ope = 'U'
                     AND a.cns_nrotra1 || '-' || a.cns_tipodoc1 <>
                            a.cns_nrotra2 || '-' || a.cns_tipodoc2
                     AND a.cns_tipodoc2 = b.cns_tipodoc
                     AND a.cns_adutra2 = b.cns_adutra
                     AND a.cns_nrotra2 = b.cns_nrotra
                     AND a.cns_emisor2 = b.cns_emisor
                     AND a.cns_fechaemi2 = b.cns_fecha_emi
                     AND b.cns_nomarch =
                            prm_tramite || '-' || prm_tipodocumento || '.tif'
                     AND a.cns_tipodoc1 = c.cns_tipodoc(+)
                     AND a.cns_adutra1 = c.cns_adutra(+)
                     AND a.cns_nrotra1 = c.cns_nrotra(+)
                     AND a.cns_emisor1 = c.cns_emisor(+)
                     AND a.cns_fechaemi1 = c.cns_fecha_emi(+)
            UNION ALL
            SELECT   b.cns_codconc,
                     b.cns_adutra || ':' || u.cuo_nam cns_adutra,
                     b.cns_nrotra,
                     b.cns_tipodoc,
                     b.cns_tipodoc || ':' || t.dsc_tip dsc_tip,
                     b.cns_emisor,
                     pkg_digitalizacion.pathweb (b.cns_fecha_pro)
                     || b.cns_nomarch
                         PATH,
                     b.cns_nomarch,
                     TO_CHAR (b.cns_fecha_emi, 'dd/mm/yyyy') cns_fecha_emi,
                     TO_CHAR (b.cns_fecha_pro, 'dd/mm/yyyy') cns_fecha_pro,
                     b.cns_estado,
                     '-' cns_usuario,
                     TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi') cns_fechasys
              FROM   digital.general_otro1 b,
                     untipdoc t,
                     ops$asy.uncuotab@basy.sidunealin u
             WHERE       b.cns_tipodoc = t.key_tip
                     AND b.cns_adutra = u.cuo_cod(+)
                     AND u.lst_ope(+) = 'U'
                     AND t.lst_ope = 'U'
                     AND b.cns_nomarch =
                            prm_tramite || '-' || prm_tipodocumento || '.tif';
    END relaciones;

    FUNCTION recorrido2nivel1 (prm_tramite         IN     VARCHAR2,
                               prm_tipodocumento   IN     VARCHAR2,
                               prm_nodos              OUT VARCHAR2,
                               prm_tabla           IN     VARCHAR2)
        RETURN VARCHAR2
    IS
        res     VARCHAR2 (30000) := '';
        nodos   VARCHAR2 (30000) := '';
        cont    NUMBER;
    BEGIN
        nodos := prm_tramite || '-' || prm_tipodocumento || ';';

        SELECT   COUNT (1)
          INTO   cont
          FROM   (SELECT   a.cns_nrotra2 || '-' || a.cns_tipodoc2
                    --a.cns_nrotra2 || '-' || a.cns_tipodoc2
                    FROM   relacion_otro2 a, general_otro1 b
                   WHERE   a.cns_nrotra1 || '-' || a.cns_tipodoc1 <>
                               a.cns_nrotra2 || '-' || a.cns_tipodoc2
                           AND a.cns_tipodoc1 = b.cns_tipodoc
                           AND a.cns_nrotra1 = b.cns_nrotra
                           AND b.cns_nomarch =
                                     prm_tramite
                                  || '-'
                                  || prm_tipodocumento
                                  || '.tif'
                  UNION ALL
                  SELECT   a.cns_nrotra1 || '-' || a.cns_tipodoc1
                    FROM   relacion_otro2 a, general_otro1 b
                   WHERE   a.cns_nrotra1 || '-' || a.cns_tipodoc1 <>
                               a.cns_nrotra2 || '-' || a.cns_tipodoc2
                           AND a.cns_tipodoc2 = b.cns_tipodoc
                           AND a.cns_nrotra2 = b.cns_nrotra
                           AND b.cns_nomarch =
                                     prm_tramite
                                  || '-'
                                  || prm_tipodocumento
                                  || '.tif') tbl;

        IF (cont = 0)
        THEN
            res := '';
        ELSE
            FOR i
            IN (SELECT   DECODE (
                             c.cns_nomarch,
                             NULL,
                             a.cns_nrotra2 || '-' || a.cns_tipodoc2,
                             SUBSTR (c.cns_nomarch,
                                     0,
                                     LENGTH (c.cns_nomarch) - 4))
                             relacion
                  FROM   relacion_otro2 a, general_otro1 b, general_otro1 c
                 WHERE   a.cns_nrotra1 || '-' || a.cns_tipodoc1 <>
                             a.cns_nrotra2 || '-' || a.cns_tipodoc2
                         AND a.cns_tipodoc1 = b.cns_tipodoc
                         AND a.cns_adutra1 = b.cns_adutra
                         AND a.cns_nrotra1 = b.cns_nrotra
                         AND a.cns_emisor1 = b.cns_emisor
                         AND a.cns_fechaemi1 = b.cns_fecha_emi
                         AND b.cns_nomarch =
                                   prm_tramite
                                || '-'
                                || prm_tipodocumento
                                || '.tif'
                         AND a.cns_tipodoc2 = c.cns_tipodoc(+)
                         AND a.cns_adutra2 = c.cns_adutra(+)
                         AND a.cns_nrotra2 = c.cns_nrotra(+)
                         AND a.cns_emisor2 = c.cns_emisor(+)
                         AND a.cns_fechaemi2 = c.cns_fecha_emi(+)
                UNION ALL
                SELECT   DECODE (
                             c.cns_nomarch,
                             NULL,
                             a.cns_nrotra1 || '-' || a.cns_tipodoc1,
                             SUBSTR (c.cns_nomarch,
                                     0,
                                     LENGTH (c.cns_nomarch) - 4))
                             relacion
                  FROM   relacion_otro2 a, general_otro1 b, general_otro1 c
                 WHERE   a.cns_nrotra1 || '-' || a.cns_tipodoc1 <>
                             a.cns_nrotra2 || '-' || a.cns_tipodoc2
                         AND a.cns_tipodoc2 = b.cns_tipodoc
                         AND a.cns_adutra2 = b.cns_adutra
                         AND a.cns_nrotra2 = b.cns_nrotra
                         AND a.cns_emisor2 = b.cns_emisor
                         AND a.cns_fechaemi2 = b.cns_fecha_emi
                         AND b.cns_nomarch =
                                   prm_tramite
                                || '-'
                                || prm_tipodocumento
                                || '.tif'
                         AND a.cns_tipodoc1 = c.cns_tipodoc(+)
                         AND a.cns_adutra1 = c.cns_adutra(+)
                         AND a.cns_nrotra1 = c.cns_nrotra(+)
                         AND a.cns_emisor1 = c.cns_emisor(+)
                         AND a.cns_fechaemi1 = c.cns_fecha_emi(+))
            LOOP
                res :=
                       res
                    || prm_tramite
                    || '-'
                    || prm_tipodocumento
                    || '>'
                    || i.relacion
                    || ';';

                nodos := nodos || i.relacion || ';';
            END LOOP;
        END IF;


        prm_nodos := nodos;
        RETURN res;
    END recorrido2nivel1;


    -- DEVUELVE PARAMETRICAS

    PROCEDURE obtener_tipo_doc (prm_lstope    IN     VARCHAR2,
                                prm_nit_emi   IN     VARCHAR2,
                                c_tipo_doc       OUT sys_refcursor)
    IS
    BEGIN
        OPEN c_tipo_doc FOR
              SELECT   a.key_tip,
                       a.key_tip || ':' || a.dsc_tip dsc_tip,
                       a.lst_ope,
                       a.nit_emi
                FROM   digital.untipdoc a
               WHERE   a.lst_ope LIKE prm_lstope AND a.nit_emi LIKE prm_nit_emi
            ORDER BY   a.key_tip;
    END;


    PROCEDURE obtener_aduanas_activas (c_aduanas OUT sys_refcursor)
    IS
    BEGIN
        OPEN c_aduanas FOR
              SELECT   a.cuo_cod, a.cuo_cod || ':' || a.cuo_nam cuo_nam
                FROM   ops$asy.uncuotab@basy.sidunealin a
               WHERE   a.lst_ope = 'U' AND a.cuo_cod NOT IN ('CUO01', 'ALL')
            ORDER BY   a.cuo_cod;
    END;

    -- CONSULTAS DEL SISTEMA

    PROCEDURE consulta_por_filtro2 (
        prm_codconsignatario   IN     VARCHAR2,
        prm_tipodocumento      IN     VARCHAR2,
        prm_emisor             IN     VARCHAR2,
        prm_aduana             IN     VARCHAR2,
        prm_fechaemision_ini   IN     VARCHAR2,
        prm_fechaemision_fin   IN     VARCHAR2,
        prm_tabla              IN     VARCHAR2,
        prm_tipofecha          IN     VARCHAR2,
        c_resultado               OUT sys_refcursor)
    IS
    BEGIN
        IF prm_tipofecha = 'EMISION'
        THEN
            IF prm_tabla = 'GENERAL'
            THEN
                OPEN c_resultado FOR
                      SELECT   b.cns_codconc,
                               b.cns_adutra || ':' || u.cuo_nam cns_adutra,
                               b.cns_nrotra,
                               b.cns_tipodoc,
                               b.cns_tipodoc || ':' || t.dsc_tip dsc_tip,
                               b.cns_emisor,
                               pkg_digitalizacion.pathweb (b.cns_fecha_pro)
                               || b.cns_nomarch
                                   PATH,
                               b.cns_nomarch,
                               TO_CHAR (b.cns_fecha_emi, 'dd/mm/yyyy')
                                   cns_fecha_emi,
                               TO_CHAR (b.cns_fecha_pro, 'dd/mm/yyyy')
                                   cns_fecha_pro,
                               b.cns_estado,
                               '-' cns_usuario,
                               TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi')
                                   cns_fechasys
                        FROM   general_otro1 b,
                               untipdoc t,
                               ops$asy.uncuotab@basy.sidunealin u
                       WHERE       b.cns_tipodoc = t.key_tip
                               AND b.cns_adutra = u.cuo_cod(+)
                               AND u.lst_ope(+) = 'U'
                               AND t.lst_ope = 'U'
                               AND b.cns_tipodoc = prm_tipodocumento
                               AND b.cns_adutra = prm_aduana
                               AND b.cns_fecha_emi BETWEEN TO_DATE (
                                                               prm_fechaemision_ini,
                                                               'dd/mm/yyyy')
                                                       AND  TO_DATE (
                                                                prm_fechaemision_fin,
                                                                'dd/mm/yyyy')
                    ORDER BY   b.cns_nrotra, t.dsc_tip;
            END IF;
        END IF;

        IF prm_tipofecha = 'PROCESAMIENTO'
        THEN
            IF prm_tabla = 'GENERAL'
            THEN
                OPEN c_resultado FOR
                      SELECT   b.cns_codconc,
                               b.cns_adutra || ':' || u.cuo_nam cns_adutra,
                               b.cns_nrotra,
                               b.cns_tipodoc,
                               b.cns_tipodoc || ':' || t.dsc_tip dsc_tip,
                               b.cns_emisor,
                               pkg_digitalizacion.pathweb (b.cns_fecha_pro)
                               || b.cns_nomarch
                                   PATH,
                               b.cns_nomarch,
                               TO_CHAR (b.cns_fecha_emi, 'dd/mm/yyyy')
                                   cns_fecha_emi,
                               TO_CHAR (b.cns_fecha_pro, 'dd/mm/yyyy')
                                   cns_fecha_pro,
                               b.cns_estado,
                               '-' cns_usuario,
                               TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi')
                                   cns_fechasys
                        FROM   general_otro1 b,
                               untipdoc t,
                               ops$asy.uncuotab@basy.sidunealin u
                       WHERE       b.cns_tipodoc = t.key_tip
                               AND b.cns_adutra = u.cuo_cod(+)
                               AND u.lst_ope(+) = 'U'
                               AND t.lst_ope = 'U'
                               AND b.cns_tipodoc = prm_tipodocumento
                               AND b.cns_adutra = prm_aduana
                               AND b.cns_fecha_pro BETWEEN TO_DATE (
                                                               prm_fechaemision_ini,
                                                               'dd/mm/yyyy')
                                                       AND  TO_DATE (
                                                                prm_fechaemision_fin,
                                                                'dd/mm/yyyy')
                    ORDER BY   b.cns_nrotra, t.dsc_tip;
            END IF;
        END IF;
    END;

    PROCEDURE consulta_por_tramite2 (prm_tramite   IN     VARCHAR2,
                                     prm_tabla     IN     VARCHAR2,
                                     c_resultado      OUT sys_refcursor)
    IS
        vtramite   VARCHAR2 (30);
        vtipo      VARCHAR2 (20);
    BEGIN
        vtramite := SUBSTR (prm_tramite, 0, INSTR (prm_tramite, '-') - 1);
        vtipo := SUBSTR (prm_tramite, INSTR (prm_tramite, '-') + 1);

        IF prm_tabla = 'GENERAL'
        THEN
            OPEN c_resultado FOR
                  SELECT   b.cns_codconc,
                           b.cns_adutra || ':' || u.cuo_nam cns_adutra,
                           b.cns_nrotra,
                           b.cns_tipodoc,
                           b.cns_tipodoc || ':' || t.dsc_tip dsc_tip,
                           b.cns_emisor,
                           pkg_digitalizacion.pathweb (b.cns_fecha_pro)
                           || b.cns_nomarch
                               PATH,
                           b.cns_nomarch,
                           TO_CHAR (b.cns_fecha_emi, 'dd/mm/yyyy')
                               cns_fecha_emi,
                           TO_CHAR (b.cns_fecha_pro, 'dd/mm/yyyy')
                               cns_fecha_pro,
                           b.cns_estado,
                           '-' cns_usuario,
                           TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi') cns_fechasys
                    FROM   general_otro1 b,
                           untipdoc t,
                           ops$asy.uncuotab@basy.sidunealin u
                   WHERE       b.cns_tipodoc = t.key_tip
                           AND b.cns_adutra = u.cuo_cod(+)
                           AND u.lst_ope(+) = 'U'
                           AND t.lst_ope = 'U'
                           AND b.cns_nomarch = prm_tramite || '.tif'
                --AND b.cns_nrotra = vtramite
                --AND b.cns_tipodoc = vtipo
                ORDER BY   b.cns_nrotra, t.dsc_tip;
        END IF;
    END;

    FUNCTION ceros (numero IN VARCHAR2)
        RETURN VARCHAR2
    IS
        res   VARCHAR2 (20);
    BEGIN
        SELECT   DECODE (LENGTH (numero),
                         1, '00000' || numero,
                         2, '0000' || numero,
                         3, '000' || numero,
                         4, '00' || numero,
                         5, '0' || numero,
                         numero)
          INTO   res
          FROM   DUAL;

        RETURN res;
    END;

    FUNCTION PATH (fecha IN DATE)
        RETURN VARCHAR2
    IS
        res   VARCHAR2 (100);
    BEGIN
        SELECT      '\u03\oracle\user_projects\data\digital\Gestion '
                 || TO_CHAR (fecha, 'yyyy')
                 || '\'
                 || DECODE (TO_CHAR (fecha, 'mm'),
                            '01', '1 Trimestre',
                            '02', '1 Trimestre',
                            '03', '1 Trimestre',
                            '04', '2 Trimestre',
                            '05', '2 Trimestre',
                            '06', '2 Trimestre',
                            '07', '3 Trimestre',
                            '08', '3 Trimestre',
                            '09', '3 Trimestre',
                            '10', '4 Trimestre',
                            '11', '4 Trimestre',
                            '12', '4 Trimestre',
                            '-')
                 || '\'
          INTO   res
          FROM   DUAL;

        RETURN res;
    END;


    FUNCTION pathweb (fecha IN DATE)
        RETURN VARCHAR2
    IS
        res   VARCHAR2 (100);
    BEGIN
        SELECT      '/digitalizacion/digital/Gestion '
                 || TO_CHAR (fecha, 'yyyy')
                 || '/'
                 || DECODE (TO_CHAR (fecha, 'mm'),
                            '01', '1 Trimestre',
                            '02', '1 Trimestre',
                            '03', '1 Trimestre',
                            '04', '2 Trimestre',
                            '05', '2 Trimestre',
                            '06', '2 Trimestre',
                            '07', '3 Trimestre',
                            '08', '3 Trimestre',
                            '09', '3 Trimestre',
                            '10', '4 Trimestre',
                            '11', '4 Trimestre',
                            '12', '4 Trimestre',
                            '-')
                 || '/'
          INTO   res
          FROM   DUAL;

        RETURN res;
    END;
END;
/

