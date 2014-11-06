#ifndef USER_CLASS
#define USER_CLASS
#include <vector>
#include <memory>

using namespace std;

//Måste definera SQL_Control eftersom att de beror på varandra
//class SQL_Control;
//Måste göras i SQL_Control också, fast för User. så, "class User;" alltså.

class User{
public:
  User(const string & _username,const string & _name,const string & _surname,const int & _id,const vector<User> & _debts = {} ): username_{_username}, name_{_name}, surname_{_surname}, id_{_id}, debts{_debts}{};
  ~User() = default;
  string name() const {return name_;}
  string surname() const {return surname_;}
  string username() const {return username_;}
  shared_ptr<vector<User> > get_debts() const;
  virtual bool change_debt (const string & _username, const double & debt) = 0;
  
private:
  string username_; 
  string name_;
  string surname_;
  int id_;
protected:
  vector<User> debts;
};


shared_ptr<vector<User> > User::get_debts() const{
  
  shared_ptr<vector<User> > tmp = make_shared<vector<User> >(debts);
  return tmp;
}


class Contact: public User{
public:
  
  virtual bool change_debt(const string & _username, const double & _debt) final;
private:
  double debt;
};

bool Contact::change_debt(const string & _username, const double & _debt){
  debt += _debt;
  return true;
}


class Self: public User{
public:
  Self(const string & _username,const string & _name,const string & _surname,const int & _id,const string & _email,const  vector<User> & _debts = {} ):User(_username,_name,_surname,_id), email_{_email}, total_debt{0}/*, sql{SQL_Control()}*/{}
  ~Self() = default;
  
  string email() const {return email_;}
  double total() const {return total_debt;}

  bool refresh();
  bool update();
  virtual bool change_debt(const string & _username, const double & debt) final;
  
private:
  string email_;
  double total_debt;
  vector<User> update_list;
  //SQL_Control sql;
};

bool Self::refresh(){
  /* Från designspecifikation:
  Refresh, tar inga parametrar och returnerar en bool om det gick bra eller inte. Den ber
  ”SQL_control” att hämta information om skulderna och uppdaterar total_debt, sedan returnerar
  den true. Om ingen kontakt kunde nås med databasen returneras false.
  */
  
}

bool Self::update(){
  /* Från designspecifikation:
  Update, tar inga parametrar och returnerar en bool. Update kallar ”SQL_control::update” för alla
  kontakter i updatelistan. True returneras om det gick bra att skriva över skuldfältet, annars false.
  */
  
  for(auto & user: update_list){
    if(user.name() == "") //if(!sql.update(user) return false;
      return false;
  }
  //return sql.update(*this);
  return true;
}

 bool Self::change_debt(const string & _username, const double & debt){
  /* Från designspecifikation:
  Change_debt, tar en double och en sträng som parametrar. Dessa ska representera förändring av
  skuld samt användarnamn. Först söker igenom nuvarande skulder och ser om användarnamnet
  redan finns bland skulderna. Om användarnamnet finns så ändras den befintliga skulden och
  lägger till kontakten i update-listan, om skulden blir 0 så tas den bort, sedan kallas update och
  true returneras. Om användarnamnet inte finns bland skulderna ber den ”SQL_control” att söka i
  databasen efter användarnamnet, hittas användarnamnet läggs en ny skuld till i skuldlistan,
  kontakten läggs även till i update-listan. Update kallas och true returneras, i övriga fall returneras
  false.
  */
  
  for(auto & user: debts){
    
    shared_ptr<User> usr = make_shared<User>(user);
    shared_ptr<Contact> cont = std::dynamic_pointer_cast<Contact>(usr);
    if(cont){
      if(user.username() == _username){
        user.change_debt("", debt);
        update_list.push_back(user);
      }
    }else{
      return false;
    }
  }
  return true;
}



class Not_Complete: public User{
public:
  
private:
  double debt;
};

#endif


