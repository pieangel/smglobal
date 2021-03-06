unit ClePaveOrderType;

interface

uses
  SysUtils
  ;

type

  TLayOrderParam = record
    UseL : boolean;
    LStartPrc : double;
    LCnlPrc   : double;

    UseSS : boolean;
    SStartPrc: double;
    SCnlPrc  : double;

    OrdQty  : integer;
    OrdGap  : integer;
    OrdCnt  : integer;

    LossVol : integer;
    LossPer : integer;

    EndTime : TDateTime;
    CnlHour : integer;
    CnlTick : integer;

    function ParamDesc : string;
  end;


  procedure DoLog( stLog : string; stSufix : string = '' );

implementation

uses
  GAppEnv , GleLib
  ;

procedure DoLog( stLog : string ; stSufix : string);
begin
  if stSufix <> '' then
    stSufix := FormatDateTime('yyyymmdd', Date ) + '_'+ stSufix;
  gEnv.EnvLog( WIN_ENTRY, stLog, false, stSufix);
end;


{ TLayOrderParam }

function TLayOrderParam.ParamDesc: string;
begin
  REsult := Format('L:%s,%.2f,%.2f  S:%s,%.2f,%.2f,' +
                   '%d, %d, %d, loss:%d,%d  %s, %d',  [
                   ifThenStr( UseL,  'True','False'), LStartPrc , LCnlPrc,
                   ifThenStr( UseSS, 'True','False'), SStartPrc , SCnlPrc,
                   OrdQty, OrdGap, OrdCnt,  LossVol, LossPer,
                   FormatDateTime('hh:nn:ss', EndTime), CnlHour] );
end;


end.
