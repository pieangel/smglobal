unit GAppConsts;

interface

const
  DIR_DATA = 'database';
  DIR_OUTPUT = 'output';
  DIR_QUOTEFILES = 'quotefiles';
  DIR_FILLFILES = 'fillfiles';
  DIR_TEMPLATE  = 'Template';
  DIR_LOG = 'log';
  DIR_SIMUL = 'simulation';
  DIR_ENV = 'env';
  // 하나 금융
  //DIR_TRAN = 'TranRes';
  //DIR_REAL = 'RealRes';


  FILE_UPDATER = 'grLauncher.exe';   //  실제 이름..
  FILE_NEW_UPDATE ='grLauncher_new.exe';   //  ftp 에서 받은..  --> FILE_UPDATER 로  이름을 바꿔준다.
  FILE_ENV = 'env.lsg';
  WIN_ENV= 'quoting.lsg';
  FILE_INI = 'config.ini';
  TIMER_ITEM = 'timer.lsg';
  FILE_HOLIDAYS = 'env/holidays.txt';
  FILE_LPCODE = 'elwlp.ini';
  FILE_ENV2  = 'kr_env.ini';
  FILE_ACNT  = 'VirAcnt.xml';

  FILE_PMITEM = 'outbo_mark.tbl';// 'PMItem.lsg';
  FILE_KR_FUND  = '\kr_fund.lsc';
  FILE_FAVOR_SYMBOL = '\faver_Symbol.lsc';
  FILE_ACNT_INFO = 'acnt_info.lsg';
  GURU_VERSION = 1;

implementation

end.
