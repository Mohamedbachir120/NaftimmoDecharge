class Equipe {
  int YEAR;
  String INV_ID;
  String COP_ID;
  String EMP_ID;
  String EMP_FULLNAME;
  String JOB_LIB;
  String GROUPE_ID;
  int EMP_IS_MANAGER;

  Equipe(
      {required this.YEAR,
      required this.INV_ID,
      required this.COP_ID,
      required this.EMP_ID,
      required this.EMP_FULLNAME,
      required this.JOB_LIB,
      required this.GROUPE_ID,
      required this.EMP_IS_MANAGER});

  Map<String, dynamic> toMap() {

    return {
      'year':YEAR,
      'inv_ID':INV_ID,
      'cop_ID':COP_ID,
      'emp_ID':EMP_ID,
      'emp_FULLNAME':EMP_FULLNAME,
      'groupe_ID':GROUPE_ID,
      'emp_IS_MANAGER':EMP_IS_MANAGER,
      'job_LIB':JOB_LIB,
    

    };

  }





}
