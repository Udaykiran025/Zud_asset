CLASS LHC_RAP_TDAT_CTS DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS:
      GET
        RETURNING
          VALUE(RESULT) TYPE REF TO IF_MBC_CP_RAP_TDAT_CTS.

ENDCLASS.

CLASS LHC_RAP_TDAT_CTS IMPLEMENTATION.
  METHOD GET.
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = 'ZASSET'
                                       table_entity_relations = VALUE #(
                                         ( entity = 'Asset' table = 'ZASSET' )
                                       ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS LHC_ZI_ASSET_S DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_INSTANCE_FEATURES FOR INSTANCE FEATURES
        IMPORTING
          KEYS REQUEST requested_features FOR AssetAll
        RESULT result,
      SELECTCUSTOMIZINGTRANSPTREQ FOR MODIFY
        IMPORTING
          KEYS FOR ACTION AssetAll~SelectCustomizingTransptReq
        RESULT result,
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR AssetAll
        RESULT result.
ENDCLASS.

CLASS LHC_ZI_ASSET_S IMPLEMENTATION.
  METHOD GET_INSTANCE_FEATURES.
    DATA: edit_flag            TYPE abp_behv_op_ctrl    VALUE if_abap_behv=>fc-o-enabled
         ,transport_feature    TYPE abp_behv_field_ctrl VALUE if_abap_behv=>fc-f-mandatory
         ,selecttransport_flag TYPE abp_behv_op_ctrl    VALUE if_abap_behv=>fc-o-enabled.

    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    IF lhc_rap_tdat_cts=>get( )->is_transport_mandatory( ) = abap_false.
      transport_feature = if_abap_behv=>fc-f-unrestricted.
    ENDIF.
    result = VALUE #( FOR key in keys (
               %TKY = key-%TKY
               %ACTION-edit = edit_flag
               %ASSOC-_Asset = edit_flag
               %FIELD-TransportRequestID = transport_feature
               %ACTION-SelectCustomizingTransptReq = COND #( WHEN key-%IS_DRAFT = if_abap_behv=>mk-off
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD SELECTCUSTOMIZINGTRANSPTREQ.
    MODIFY ENTITIES OF ZI_Asset_S IN LOCAL MODE
      ENTITY AssetAll
        UPDATE FIELDS ( TransportRequestID )
        WITH VALUE #( FOR key IN keys
                        ( %TKY               = key-%TKY
                          TransportRequestID = key-%PARAM-transportrequestid
                         ) ).

    READ ENTITIES OF ZI_Asset_S IN LOCAL MODE
      ENTITY AssetAll
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %TKY   = entity-%TKY
                          %PARAM = entity ) ).
  ENDMETHOD.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
*    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD 'ZI_ASSET' ID 'ACTVT' FIELD '02'.
*    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
*                                  ELSE if_abap_behv=>auth-unauthorized ).
*    result-%UPDATE      = is_authorized.
*    result-%ACTION-Edit = is_authorized.
*    result-%ACTION-SelectCustomizingTransptReq = is_authorized.
  ENDMETHOD.
ENDCLASS.
CLASS LSC_ZI_ASSET_S DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_SAVER.
  PROTECTED SECTION.
    METHODS:
      SAVE_MODIFIED REDEFINITION.
ENDCLASS.

CLASS LSC_ZI_ASSET_S IMPLEMENTATION.
  METHOD SAVE_MODIFIED.
    DATA(transport_from_singleton) = VALUE #( update-AssetAll[ 1 ]-TransportRequestID OPTIONAL ).
    IF transport_from_singleton IS NOT INITIAL.
      lhc_rap_tdat_cts=>get( )->record_changes(
                                  transport_request = transport_from_singleton
                                  create            = REF #( create )
                                  update            = REF #( update )
                                  delete            = REF #( delete ) ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
CLASS LHC_ZI_ASSET DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_FEATURES FOR GLOBAL FEATURES
        IMPORTING
          REQUEST REQUESTED_FEATURES FOR Asset
        RESULT result,
      COPYASSET FOR MODIFY
        IMPORTING
          KEYS FOR ACTION Asset~CopyAsset,
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR Asset
        RESULT result,
      GET_INSTANCE_FEATURES FOR INSTANCE FEATURES
        IMPORTING
          KEYS REQUEST requested_features FOR Asset
        RESULT result,
      VALIDATETRANSPORTREQUEST FOR VALIDATE ON SAVE
        IMPORTING
          KEYS_ASSETALL FOR AssetAll~ValidateTransportRequest
          KEYS_ASSET FOR Asset~ValidateTransportRequest.
ENDCLASS.

CLASS LHC_ZI_ASSET IMPLEMENTATION.
  METHOD GET_GLOBAL_FEATURES.
    DATA edit_flag TYPE abp_behv_op_ctrl VALUE if_abap_behv=>fc-o-enabled.
    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%UPDATE = edit_flag.
    result-%DELETE = edit_flag.
  ENDMETHOD.
  METHOD COPYASSET.
    DATA new_Asset TYPE TABLE FOR CREATE ZI_Asset_S\_Asset.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-Asset = VALUE #( FOR fkey IN keys ( %TKY = fkey-%TKY ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF ZI_Asset_S IN LOCAL MODE
      ENTITY Asset
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(ref_Asset)
        FAILED DATA(read_failed).

    IF ref_Asset IS NOT INITIAL.
      ASSIGN ref_Asset[ 1 ] TO FIELD-SYMBOL(<ref_Asset>).
      DATA(key) = keys[ KEY draft %TKY = <ref_Asset>-%TKY ].
      DATA(key_cid) = key-%CID.
      APPEND VALUE #(
        %TKY-SingletonID = 1
        %IS_DRAFT = <ref_Asset>-%IS_DRAFT
        %TARGET = VALUE #( (
          %CID = key_cid
          %IS_DRAFT = <ref_Asset>-%IS_DRAFT
          %DATA = CORRESPONDING #( <ref_Asset> EXCEPT
          SingletonID
          LocalLastChangedAt
          ChangedAt
        ) ) )
      ) TO new_Asset ASSIGNING FIELD-SYMBOL(<new_Asset>).
      <new_Asset>-%TARGET[ 1 ]-ZzPbukr = to_upper( key-%PARAM-ZzPbukr ).

      MODIFY ENTITIES OF ZI_Asset_S IN LOCAL MODE
        ENTITY AssetAll CREATE BY \_Asset
        FIELDS (
                 ZzPbukr
                 ExternalId
                 ZzProjManager
                 Assetclass
                 Assetclassdes
                 Aktiv
                 ZzKostlResp
                 Anlhtxt
                 ChangedBy
               ) WITH new_Asset
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.

      mapped-Asset = mapped_create-Asset.
    ENDIF.

    INSERT LINES OF read_failed-Asset INTO TABLE failed-Asset.

    IF failed-Asset IS INITIAL.
      reported-Asset = VALUE #( FOR created IN mapped-Asset (
                                                 %CID = created-%CID
                                                 %ACTION-CopyAsset = if_abap_behv=>mk-on
                                                 %MSG = mbc_cp_api=>message( )->get_item_copied( )
                                                 %PATH-AssetAll-%IS_DRAFT = created-%IS_DRAFT
                                                 %PATH-AssetAll-SingletonID = 1 ) ).
    ENDIF.
  ENDMETHOD.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
*    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD 'ZI_ASSET' ID 'ACTVT' FIELD '02'.
*    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
*                                  ELSE if_abap_behv=>auth-unauthorized ).
*    result-%ACTION-CopyAsset = is_authorized.
  ENDMETHOD.
  METHOD GET_INSTANCE_FEATURES.
    result = VALUE #( FOR row IN keys ( %TKY = row-%TKY
                                        %ACTION-CopyAsset = COND #( WHEN row-%IS_DRAFT = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
    ) ).
  ENDMETHOD.
  METHOD VALIDATETRANSPORTREQUEST.
*    CHECK keys_Asset IS NOT INITIAL.
*    DATA change TYPE REQUEST FOR CHANGE ZI_Asset_S.
*    READ ENTITY IN LOCAL MODE ZI_Asset_S
*    FIELDS ( TransportRequestID ) WITH CORRESPONDING #( keys_AssetAll )
*    RESULT FINAL(transport_from_singleton).
*    lhc_rap_tdat_cts=>get( )->validate_all_changes(
*                                transport_request     = VALUE #( transport_from_singleton[ 1 ]-TransportRequestID OPTIONAL )
*                                table_validation_keys = VALUE #(
*                                                          ( table = 'ZASSET' keys = REF #( keys_Asset ) )
*                                                               )
*                                reported              = REF #( reported )
*                                failed                = REF #( failed )
*                                change                = REF #( change ) ).
  ENDMETHOD.
ENDCLASS.
