class LoginInfo{
  String username;
  String password;
   LoginInfo({required this.username,required this.password});

    Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        
      };

}