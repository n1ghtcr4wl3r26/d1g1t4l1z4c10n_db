CREATE OR REPLACE 
PACKAGE pkg_digitalizacion
/* Formatted on 3-may.-2017 16:31:14 (QP5 v5.126) */
IS
    -- RECURSIVIDAD

    FUNCTION factorial (num IN NUMBER)
        RETURN NUMBER;

    FUNCTION recorrido (prm_tramite       IN     VARCHAR2,
                        prm_padre         IN     VARCHAR2,
                        prm_nodos         IN OUT VARCHAR2,
                        prm_tabla         IN     VARCHAR2,
                        prm_limite        IN     NUMBER,
                        prm_profundidad   IN     NUMBER)
        RETURN VARCHAR2;

    FUNCTION recorrido2 (prm_tramite   IN     VARCHAR2,
                         prm_nodos        OUT VARCHAR2,
                         prm_tabla     IN     VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION recorridonivel1 (prm_tramite   IN     VARCHAR2,
                              prm_nodos        OUT VARCHAR2,
                              prm_tabla     IN     VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION recorrido2nivel1 (prm_tramite         IN     VARCHAR2,
                               prm_tipodocumento   IN     VARCHAR2,
                               prm_nodos              OUT VARCHAR2,
                               prm_tabla           IN     VARCHAR2)
        RETURN VARCHAR2;

    -- DEVUELVE PARAMETRICAS

    PROCEDURE obtener_tipo_doc (prm_lstope    IN     VARCHAR2,
                                prm_nit_emi   IN     VARCHAR2,
                                c_tipo_doc       OUT sys_refcursor);

    PROCEDURE obtener_aduanas_activas (c_aduanas OUT sys_refcursor);

    -- CONSULTAS DEL SISTEMA

    PROCEDURE consulta_por_filtro (
        prm_codconsignatario   IN     VARCHAR2,
        prm_tipodocumento      IN     VARCHAR2,
        prm_emisor             IN     VARCHAR2,
        prm_aduana             IN     VARCHAR2,
        prm_fechaemision_ini   IN     VARCHAR2,
        prm_fechaemision_fin   IN     VARCHAR2,
        prm_tabla              IN     VARCHAR2,
        c_resultado               OUT sys_refcursor);

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

    PROCEDURE consulta_por_dui (prm_gestion   IN     VARCHAR2,
                                prm_aduana    IN     VARCHAR2,
                                prm_numero    IN     VARCHAR2,
                                prm_tabla     IN     VARCHAR2,
                                c_resultado      OUT sys_refcursor);

    PROCEDURE consulta_por_tramite (prm_tramite   IN     VARCHAR2,
                                    prm_tabla     IN     VARCHAR2,
                                    c_resultado      OUT sys_refcursor);

    PROCEDURE consulta_por_tramite2 (prm_tramite   IN     VARCHAR2,
                                     prm_tabla     IN     VARCHAR2,
                                     c_resultado      OUT sys_refcursor);

    -- LOG DEL SISTEMA

    PROCEDURE obtener_logs (i_app        IN     VARCHAR2,
                            i_nivel      IN     VARCHAR2,
                            i_mensaje    IN     VARCHAR2,
                            i_desde      IN     VARCHAR2,
                            i_hasta      IN     VARCHAR2,
                            i_cantidad   IN     NUMBER,
                            c_logs          OUT sys_refcursor);

    PROCEDURE guardar_log (i_app          IN VARCHAR2,
                           i_nivel        IN VARCHAR2,
                           i_mensaje      IN VARCHAR2,
                           i_usuario      IN VARCHAR2,
                           i_tipo         IN VARCHAR2,
                           i_ip           IN VARCHAR2,
                           i_referencia   IN VARCHAR2);

    FUNCTION ceros (numero IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION PATH (fecha IN DATE)
        RETURN VARCHAR2;

    FUNCTION pathweb (fecha IN DATE)
        RETURN VARCHAR2;

    PROCEDURE busca_tramite (prm_tramite   IN     VARCHAR2,
                             prm_tabla     IN     VARCHAR2,
                             c_resultado      OUT sys_refcursor);
END;
/

CREATE OR REPLACE 
PACKAGE BODY pkg_digitalizacion
/* Formatted on 3-may.-2017 19:31:37 (QP5 v5.126) */
IS
    -- RECURSIVIDAD

    FUNCTION factorial (num IN NUMBER)
        RETURN NUMBER
    IS
        res   NUMBER (18);
    BEGIN
        IF (num < 2)
        THEN
            res := 1;
        ELSE
            res := num * factorial (num - 1);
        END IF;

        RETURN res;
    END factorial;


    FUNCTION recorrido (prm_tramite       IN     VARCHAR2,
                        prm_padre         IN     VARCHAR2,
                        prm_nodos         IN OUT VARCHAR2,
                        prm_tabla         IN     VARCHAR2,
                        prm_limite        IN     NUMBER,
                        prm_profundidad   IN     NUMBER)
        RETURN VARCHAR2
    IS
        res     VARCHAR2 (30000) := '';
        nodos   VARCHAR2 (30000) := '';
        cont    NUMBER;
    BEGIN
        nodos := prm_nodos;

        IF prm_tabla = 'GENERAL'
        THEN
            SELECT   COUNT (1)
              INTO   cont
              FROM   relacion_otro2 a
             WHERE   a.cns_nrotra1 <> a.cns_nrotra2
                     AND ( (a.cns_nrotra1 = prm_tramite
                            AND a.cns_nrotra2 <> prm_padre)
                          OR (a.cns_nrotra2 = prm_tramite
                              AND a.cns_nrotra1 <> prm_padre));

            IF (cont = 0 OR prm_limite = prm_profundidad)
            THEN
                res := '';
            ELSE
                FOR i
                IN (SELECT   DECODE (a.cns_nrotra1,
                                     prm_tramite, a.cns_nrotra2,
                                     a.cns_nrotra1)
                                 relacion
                      FROM   relacion_otro2 a
                     WHERE   a.cns_nrotra1 <> a.cns_nrotra2
                             AND ( (a.cns_nrotra1 = prm_tramite
                                    AND a.cns_nrotra2 <> prm_padre)
                                  OR (a.cns_nrotra2 = prm_tramite
                                      AND a.cns_nrotra1 <> prm_padre)))
                LOOP
                    res := res || prm_tramite || '>' || i.relacion || ';';

                    IF (INSTR (prm_nodos, i.relacion) = 0)
                    THEN
                        nodos := nodos || i.relacion || ';';
                        res :=
                            res
                            || recorrido (i.relacion,
                                          prm_tramite,
                                          nodos,
                                          prm_tabla,
                                          prm_limite,
                                          prm_profundidad + 1);
                    END IF;
                END LOOP;
            END IF;
        END IF;

        prm_nodos := nodos;
        RETURN res;
    END recorrido;


    FUNCTION recorrido2 (prm_tramite   IN     VARCHAR2,
                         prm_nodos        OUT VARCHAR2,
                         prm_tabla     IN     VARCHAR2)
        RETURN VARCHAR2
    IS
        res     VARCHAR2 (30000) := '';
        nodos   VARCHAR2 (30000) := '';
        cont    NUMBER;
    BEGIN
        nodos := prm_tramite || ';';
        res :=
            recorrido (prm_tramite,
                       '-',
                       nodos,
                       prm_tabla,
                       2,
                       1);

        prm_nodos := nodos;
        RETURN res;
    END recorrido2;



    FUNCTION recorridonivel1 (prm_tramite   IN     VARCHAR2,
                              prm_nodos        OUT VARCHAR2,
                              prm_tabla     IN     VARCHAR2)
        RETURN VARCHAR2
    IS
        res     VARCHAR2 (10000) := '';
        nodos   VARCHAR2 (10000) := '';
        cont    NUMBER;
    BEGIN
        nodos := prm_tramite || ';';


        IF prm_tabla = 'GENERAL'
        THEN
            SELECT   COUNT (1)
              INTO   cont
              FROM   relacion_otro2 a
             WHERE   a.cns_nrotra1 <> a.cns_nrotra2
                     AND (a.cns_nrotra1 = prm_tramite
                          OR a.cns_nrotra2 = prm_tramite);


            IF (cont = 0)
            THEN
                res := '';
            ELSE
                FOR i
                IN (SELECT   DECODE (a.cns_nrotra1,
                                     prm_tramite, a.cns_nrotra2,
                                     a.cns_nrotra1)
                                 relacion
                      FROM   relacion_otro2 a
                     WHERE   a.cns_nrotra1 <> a.cns_nrotra2
                             AND (a.cns_nrotra1 = prm_tramite
                                  OR a.cns_nrotra2 = prm_tramite))
                LOOP
                    res := res || prm_tramite || '>' || i.relacion || ';';

                    nodos := nodos || i.relacion || ';';
                END LOOP;
            END IF;
        END IF;

        prm_nodos := nodos;
        RETURN res;
    END recorridonivel1;

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
        nodos := prm_tramite || '*' || prm_tipodocumento || ';';

        IF    prm_tipodocumento = '960'
           OR prm_tipodocumento = '932'
           OR prm_tipodocumento = 'B74'
        THEN
            SELECT   COUNT (1)
              INTO   cont
              FROM   relacion_otro2 a
             WHERE   a.cns_nrotra1 || '*' || a.cns_tipodoc1 <>
                         a.cns_nrotra2 || '*' || a.cns_tipodoc2
                     AND ( (SUBSTR (a.cns_nrotra1, 0, 7) =
                                SUBSTR (prm_tramite, 0, 7)
                            AND TRIM ('0' FROM SUBSTR (a.cns_nrotra1, 9)) =
                                   TRIM ('0' FROM SUBSTR (prm_tramite, 9))
                            AND a.cns_tipodoc1 = prm_tipodocumento)
                          OR (SUBSTR (a.cns_nrotra2, 0, 7) =
                                  SUBSTR (prm_tramite, 0, 7)
                              AND TRIM ('0' FROM SUBSTR (a.cns_nrotra2, 9)) =
                                     TRIM ('0' FROM SUBSTR (prm_tramite, 9))
                              AND a.cns_tipodoc2 = prm_tipodocumento));

            IF (cont = 0)
            THEN
                res := '';
            ELSE
                FOR i
                IN (SELECT   DECODE (a.cns_nrotra1,
                                     prm_tramite,
                                     a.cns_nrotra2 || '*' || a.cns_tipodoc2,
                                     a.cns_nrotra1 || '*' || a.cns_tipodoc1)
                                 relacion
                      FROM   relacion_otro2 a
                     WHERE   a.cns_nrotra1 || '*' || a.cns_tipodoc1 <>
                                 a.cns_nrotra2 || '*' || a.cns_tipodoc2
                             AND ( (SUBSTR (a.cns_nrotra1, 0, 7) =
                                        SUBSTR (prm_tramite, 0, 7)
                                    AND TRIM (
                                           '0' FROM SUBSTR (a.cns_nrotra1, 9)) =
                                           TRIM (
                                               '0' FROM SUBSTR (prm_tramite,
                                                                9))
                                    AND a.cns_tipodoc1 = prm_tipodocumento)
                                  OR (SUBSTR (a.cns_nrotra2, 0, 7) =
                                          SUBSTR (prm_tramite, 0, 7)
                                      AND TRIM (
                                             '0' FROM SUBSTR (a.cns_nrotra2,
                                                              9)) =
                                             TRIM (
                                                 '0' FROM SUBSTR (
                                                              prm_tramite,
                                                              9))
                                      AND a.cns_tipodoc2 = prm_tipodocumento)))
                LOOP
                    res :=
                           res
                        || prm_tramite
                        || '*'
                        || prm_tipodocumento
                        || '>'
                        || i.relacion
                        || ';';

                    nodos := nodos || i.relacion || ';';
                END LOOP;
            END IF;
        ELSE
            IF prm_tipodocumento = '785'
            THEN
                SELECT   COUNT (1)
                  INTO   cont
                  FROM   relacion_otro2 a
                 WHERE   a.cns_nrotra1 || '*' || a.cns_tipodoc1 <>
                             a.cns_nrotra2 || '*' || a.cns_tipodoc2
                         AND ( (SUBSTR (a.cns_nrotra1, 0, 7) =
                                    SUBSTR (prm_tramite, 0, 7)
                                AND TRIM ('0' FROM SUBSTR (a.cns_nrotra1, 8)) =
                                       TRIM (
                                           '0' FROM SUBSTR (prm_tramite, 8))
                                AND a.cns_tipodoc1 = prm_tipodocumento)
                              OR (SUBSTR (a.cns_nrotra2, 0, 7) =
                                      SUBSTR (prm_tramite, 0, 7)
                                  AND TRIM (
                                         '0' FROM SUBSTR (a.cns_nrotra2, 8)) =
                                         TRIM (
                                             '0' FROM SUBSTR (prm_tramite, 8))
                                  AND a.cns_tipodoc2 = prm_tipodocumento));

                IF (cont = 0)
                THEN
                    res := '';
                ELSE
                    FOR i
                    IN (SELECT   DECODE (
                                     a.cns_nrotra1,
                                     prm_tramite,
                                     a.cns_nrotra2 || '*' || a.cns_tipodoc2,
                                     a.cns_nrotra1 || '*' || a.cns_tipodoc1)
                                     relacion
                          FROM   relacion_otro2 a
                         WHERE   a.cns_nrotra1 || '*' || a.cns_tipodoc1 <>
                                     a.cns_nrotra2 || '*' || a.cns_tipodoc2
                                 AND ( (SUBSTR (a.cns_nrotra1, 0, 7) =
                                            SUBSTR (prm_tramite, 0, 7)
                                        AND TRIM (
                                               '0' FROM SUBSTR (
                                                            a.cns_nrotra1,
                                                            8)) =
                                               TRIM (
                                                   '0' FROM SUBSTR (
                                                                prm_tramite,
                                                                8))
                                        AND a.cns_tipodoc1 =
                                               prm_tipodocumento)
                                      OR (SUBSTR (a.cns_nrotra2, 0, 7) =
                                              SUBSTR (prm_tramite, 0, 7)
                                          AND TRIM (
                                                 '0' FROM SUBSTR (
                                                              a.cns_nrotra2,
                                                              8)) =
                                                 TRIM (
                                                     '0' FROM SUBSTR (
                                                                  prm_tramite,
                                                                  8))
                                          AND a.cns_tipodoc2 =
                                                 prm_tipodocumento)))
                    LOOP
                        res :=
                               res
                            || prm_tramite
                            || '*'
                            || prm_tipodocumento
                            || '>'
                            || i.relacion
                            || ';';

                        nodos := nodos || i.relacion || ';';
                    END LOOP;
                END IF;
            ELSE
                SELECT   COUNT (1)
                  INTO   cont
                  FROM   relacion_otro2 a
                 WHERE   a.cns_nrotra1 || '*' || a.cns_tipodoc1 <>
                             a.cns_nrotra2 || '*' || a.cns_tipodoc2
                         AND (a.cns_nrotra1 = prm_tramite
                              AND a.cns_tipodoc1 = prm_tipodocumento)
                         OR (a.cns_nrotra2 = prm_tramite
                             AND a.cns_tipodoc2 = prm_tipodocumento);

                IF (cont = 0)
                THEN
                    res := '';
                ELSE
                    FOR i
                    IN (SELECT   DECODE (
                                     a.cns_nrotra1,
                                     prm_tramite,
                                     a.cns_nrotra2 || '*' || a.cns_tipodoc2,
                                     a.cns_nrotra1 || '*' || a.cns_tipodoc1)
                                     relacion
                          FROM   relacion_otro2 a
                         WHERE   a.cns_nrotra1 || '*' || a.cns_tipodoc1 <>
                                     a.cns_nrotra2 || '*' || a.cns_tipodoc2
                                 AND (a.cns_nrotra1 = prm_tramite
                                      AND a.cns_tipodoc1 = prm_tipodocumento)
                                 OR (a.cns_nrotra2 = prm_tramite
                                     AND a.cns_tipodoc2 = prm_tipodocumento))
                    LOOP
                        res :=
                               res
                            || prm_tramite
                            || '*'
                            || prm_tipodocumento
                            || '>'
                            || i.relacion
                            || ';';

                        nodos := nodos || i.relacion || ';';
                    END LOOP;
                END IF;
            END IF;
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

    PROCEDURE consulta_por_filtro (
        prm_codconsignatario   IN     VARCHAR2,
        prm_tipodocumento      IN     VARCHAR2,
        prm_emisor             IN     VARCHAR2,
        prm_aduana             IN     VARCHAR2,
        prm_fechaemision_ini   IN     VARCHAR2,
        prm_fechaemision_fin   IN     VARCHAR2,
        prm_tabla              IN     VARCHAR2,
        c_resultado               OUT sys_refcursor)
    IS
    BEGIN
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
                           --AND b.cns_codconc LIKE prm_codconsignatario
                           AND b.cns_tipodoc LIKE prm_tipodocumento
                           --AND b.cns_emisor LIKE prm_emisor
                           AND b.cns_adutra LIKE prm_aduana
                           AND b.cns_fecha_emi BETWEEN TO_DATE (
                                                           prm_fechaemision_ini,
                                                           'dd/mm/yyyy')
                                                   AND  TO_DATE (
                                                            prm_fechaemision_fin,
                                                            'dd/mm/yyyy')
                ORDER BY   b.cns_nrotra, t.dsc_tip;
        END IF;
    END;

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
                               --AND b.cns_codconc LIKE prm_codconsignatario
                               AND b.cns_tipodoc LIKE prm_tipodocumento
                               --AND b.cns_emisor LIKE prm_emisor
                               AND b.cns_adutra LIKE prm_aduana
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
                               --AND b.cns_codconc LIKE prm_codconsignatario
                               AND b.cns_tipodoc LIKE prm_tipodocumento
                               --AND b.cns_emisor LIKE prm_emisor
                               AND b.cns_adutra LIKE prm_aduana
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

    PROCEDURE consulta_por_dui (prm_gestion   IN     VARCHAR2,
                                prm_aduana    IN     VARCHAR2,
                                prm_numero    IN     VARCHAR2,
                                prm_tabla     IN     VARCHAR2,
                                c_resultado      OUT sys_refcursor)
    IS
    BEGIN
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
                           AND b.cns_nrotra =
                                     prm_gestion
                                  || ' '
                                  || prm_aduana
                                  || ' C '
                                  || pkg_digitalizacion.ceros (prm_numero)
                ORDER BY   b.cns_nrotra, t.dsc_tip;
        END IF;
    END;


    PROCEDURE consulta_por_tramite (prm_tramite   IN     VARCHAR2,
                                    prm_tabla     IN     VARCHAR2,
                                    c_resultado      OUT sys_refcursor)
    IS
    BEGIN
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
                           AND b.cns_nrotra = prm_tramite
                ORDER BY   b.cns_nrotra, t.dsc_tip;
        END IF;
    END;

    PROCEDURE consulta_por_tramite2 (prm_tramite   IN     VARCHAR2,
                                     prm_tabla     IN     VARCHAR2,
                                     c_resultado      OUT sys_refcursor)
    IS
        vtramite   VARCHAR2 (30);
        vtipo      VARCHAR2 (20);
    BEGIN
        vtramite := SUBSTR (prm_tramite, 0, INSTR (prm_tramite, '*') - 1);
        vtipo := SUBSTR (prm_tramite, INSTR (prm_tramite, '*') + 1);

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
                           AND b.cns_nrotra = vtramite
                           AND b.cns_tipodoc = vtipo
                ORDER BY   b.cns_nrotra, t.dsc_tip;
        END IF;
    END;


    PROCEDURE busca_tramite (prm_tramite   IN     VARCHAR2,
                             prm_tabla     IN     VARCHAR2,
                             c_resultado      OUT sys_refcursor)
    IS
        vtramite   VARCHAR2 (30);
        vtipo      VARCHAR2 (20);
    BEGIN
        vtramite := SUBSTR (prm_tramite, 0, INSTR (prm_tramite, '*') - 1);
        vtipo := SUBSTR (prm_tramite, INSTR (prm_tramite, '*') + 1);

        IF vtipo = '960' OR vtipo = '932' OR vtipo = 'B74'
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
                           AND SUBSTR (cns_nrotra, 0, 7) =
                                  SUBSTR (vtramite, 0, 7)
                           AND TRIM ('0' FROM SUBSTR (cns_nrotra, 9)) =
                                  TRIM ('0' FROM SUBSTR (vtramite, 9))
                           AND b.cns_tipodoc = vtipo
                ORDER BY   b.cns_nrotra, t.dsc_tip;
        ELSE
            IF vtipo = '785'
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
                               AND SUBSTR (cns_nrotra, 0, 7) =
                                      SUBSTR (vtramite, 0, 7)
                               AND TRIM ('0' FROM SUBSTR (cns_nrotra, 8)) =
                                      TRIM ('0' FROM SUBSTR (vtramite, 8))
                               AND b.cns_tipodoc = vtipo
                    ORDER BY   b.cns_nrotra, t.dsc_tip;
            ELSE
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
                               AND b.cns_nrotra = vtramite
                               AND b.cns_tipodoc = vtipo
                    ORDER BY   b.cns_nrotra, t.dsc_tip;
            END IF;
        END IF;
    END;

    -- LOG DEL SISTEMA

    PROCEDURE obtener_logs (i_app        IN     VARCHAR2,
                            i_nivel      IN     VARCHAR2,
                            i_mensaje    IN     VARCHAR2,
                            i_desde      IN     VARCHAR2,
                            i_hasta      IN     VARCHAR2,
                            i_cantidad   IN     NUMBER,
                            c_logs          OUT sys_refcursor)
    IS
    BEGIN
        OPEN c_logs FOR
            SELECT   *
              FROM   (  SELECT   log_id AS log_id,
                                 log_app AS app,
                                 log_nivel AS nivel,
                                 log_mensaje AS mensaje,
                                 log_ip AS ip,
                                 TO_CHAR (log_fecha, 'DD/MM/YYYY HH24:MI:SS')
                                     AS fecha,
                                 log_usuario AS usuario,
                                 log_referencia AS referencia,
                                 log_tipo AS tipo
                          FROM   digital_logs
                         WHERE   (i_nivel = '-' OR log_nivel = i_nivel)
                                 AND UPPER (log_mensaje) LIKE
                                        '%' || UPPER (i_mensaje) || '%'
                                 AND log_app = i_app
                                 AND TRUNC (log_fecha) BETWEEN TO_DATE (
                                                                   NVL (
                                                                       i_desde,
                                                                       '01/01/2000'),
                                                                   'dd/mm/yyyy')
                                                           AND  NVL (
                                                                    TO_DATE (
                                                                        i_hasta,
                                                                        'dd/mm/yyyy'),
                                                                    TRUNC(SYSDATE))
                      ORDER BY   log_id DESC)
             WHERE   ROWNUM < i_cantidad;
    END;

    PROCEDURE guardar_log (i_app          IN VARCHAR2,
                           i_nivel        IN VARCHAR2,
                           i_mensaje      IN VARCHAR2,
                           i_usuario      IN VARCHAR2,
                           i_tipo         IN VARCHAR2,
                           i_ip           IN VARCHAR2,
                           i_referencia   IN VARCHAR2)
    IS
    BEGIN
        INSERT INTO digital_logs (log_app,
                                  log_nivel,
                                  log_mensaje,
                                  log_ip,
                                  log_fecha,
                                  log_usuario,
                                  log_referencia,
                                  log_tipo)
          VALUES   (i_app,
                    i_nivel,
                    i_mensaje,
                    i_ip,
                    SYSDATE,
                    i_usuario,
                    i_referencia,
                    i_tipo);
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

