#ifndef USER_CLASS
#define USER_CLASS
#include <vector>
#include <memory>

using namespace std;

class User{
public:
  User(const string & _username,const string & _name,const int & _id,const vector<User> & _debts = {} ): username{_username}, name{_name}, surname{_surname}, id{_id}, debts{_debts}{};
  ~User() = default;
  string name() const {return name;}
  string surname() const {return surname;}
  string username() const {return username;}
  shared_ptr<vector<User> > get_debts const;
  virtual bool change_debt (const string & username, const double & debt) = 0;
  
private:
  string username; 
  string name;
  string surname;
  int id;
  vector<User> debts;
};


shared_ptr<vector<User> > User::get_debts const{
  
  shared_ptr<vector<User> > tmp = make_shared<vector<User> >(debts);
  return tmp;
}




class Self: public User{
public:
  Self(const string & _username,const string & _name,const int & _id,const string & _email,const  vector<User> & _debts = {} ):User(), email{_email}, total_debt{0}{}
  ~Self() = default;
  
  string email() const {return email;}
  double total() const {return total_debt;}
  
  
private:
  string email;
  double total_debt;
  vector<User> update_list;
};

/*
class Contact: public User{
public:
  
private:
  
};

class Not_Complete: public User{
public:
  
private:
  double debt;
};
*/
#endif


