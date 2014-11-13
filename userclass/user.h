#ifndef USER_CLASS
#define USER_CLASS
#include <vector>
#include <memory>
//#include <iterator>

using namespace std;

//Måste definera SQL_Control eftersom att de beror på varandra
//class SQL_Control;
//Måste göras i SQL_Control också, fast för User. så, "class User;" alltså.
class User;
class Contact;
class Self;
class User{
public:
  User(const string & _username,const string & _name,const string & _surname
  ,const int & _id ):
  username_{_username}, name_{_name}, surname_{_surname}, id_{_id},
  debts{std::vector<std::shared_ptr<User> >()}{};

  virtual ~User() = default;

  string name() const {return name_;}
  string surname() const {return surname_;}
  string username() const {return username_;}
  shared_ptr<vector<shared_ptr<User> > >get_debts() const;
  
  void insert_end(const vector<shared_ptr<User> > & new_debts);
  void push_back(shared_ptr<User> const & user);
  
  virtual bool change_debt (const string & _username, const double & debt) = 0;
  //virtual shared_ptr<User> clone()const = 0;
  
private:
  string username_; 
  string name_;
  string surname_;
  int id_;
protected:
  vector<shared_ptr<User> > debts;
};

void User::insert_end(vector<shared_ptr<User> >  const & new_debts){
  debts.insert(debts.end(), new_debts.begin(), new_debts.end());
}

void User::push_back(shared_ptr<User> const & user){
      debts.push_back(std::move(user));
}

shared_ptr<vector<shared_ptr<User> > >User::get_debts() const{
  
  shared_ptr<vector<shared_ptr<User> > >tmp =
  make_shared<vector<shared_ptr<User> > >(debts);
  return tmp;
}


class Contact: public User{
public:
  Contact(const string & _username,const string & _name,
  const string & _surname,const int & _id,const double & _debt):
  User(_username,_name,_surname,_id), debt_{_debt}{
  }

  virtual ~Contact()=default;

  double debt(){return debt_;}
  virtual bool change_debt(const string & _username, const double & _debt) final;
  //virtual shared_ptr<User> clone() const { return shared_ptr<Contact> (this); }
private:
  double debt_;
};

bool Contact::change_debt(const string & _username, const double & _debt){
  debt_ += _debt;
  return true;
}


class Self: public User{
public:
  Self(const string & _username,const string & _name,
  const string & _surname,const int & _id,const string & _email):
  User(_username,_name,_surname,_id), email_{_email}, total_debt{0},
  update_list{std::vector<std::shared_ptr<User> >()}{
  }
  virtual ~Self() = default;
  
  string email() const {return email_;}
  double total() const {return total_debt;}

  bool refresh();
  bool update();

  virtual bool change_debt(const string & _username, const double & debt) final;
  //virtual shared_ptr<User> clone() const { return shared_ptr<Self> (*this); }

  
private:
  string email_;
  double total_debt;
  vector<shared_ptr<User> > update_list;
  //SQL_Control sql;
};

bool Self::refresh(){
  /* Från designspecifikation:
  Refresh, tar inga parametrar och returnerar en bool om det gick bra eller inte. Den ber
  ”SQL_control” att hämta information om skulderna och uppdaterar total_debt, sedan returnerar
  den true. Om ingen kontakt kunde nås med databasen returneras false.
  */
  total_debt = 0;
  for(auto& user: debts){
    shared_ptr<Contact> cont = std::dynamic_pointer_cast<Contact>(user);
    if(cont){
      total_debt+= cont->debt();
    }
  }
}

bool Self::update(){
  /* Från designspecifikation:
  Update, tar inga parametrar och returnerar en bool. Update kallar ”SQL_control::update” för alla
  kontakter i updatelistan. True returneras om det gick bra att skriva över skuldfältet, annars false.
  */
  
  for(auto & user: update_list){
    if(user->name() == "") //if(!sql.update(user) return false;
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
    
    shared_ptr<Contact> cont = std::dynamic_pointer_cast<Contact>(user);
    if(cont){
      if(cont->username() == _username){
        cont->change_debt("", debt);
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
  Not_Complete() = default;
  Not_Complete(const string & _name, const string & _surname, const double &
  _debt):User(_name, _name, _surname, -1), debt_{_debt}{}
  ~Not_Complete()= default;
  
  virtual bool change_debt(const string & str, const double & _debt) final;
  shared_ptr<User> login(const string & _username,const string & passw);
  shared_ptr<User> create(const string & _username, const string & _name, const
  string & surname, const string & email);
private:
  double debt_;
};

bool Not_Complete::change_debt(const string & str, const double & _debt){
  debt_ += _debt;
  return true;
}


shared_ptr<User> Not_Complete::login(const string & _username,const string & passw){
  /*Från designspecifikation:
  Login kommer att ta två strängar som parametrar och returnerar en ”User”. Dessa skall vara
  användarnamnet och dess lösenord. Om de båda stämmer överens med databasen returneras
  en ”Self” från ”SQL_control”, annars returneras en ”Not_complete”. 
  */
  return make_shared<Not_Complete>("notC", "notC",-1);
  
}
shared_ptr<User> Not_Complete::create(const string & _username, const string & _name, const
  string & surname, const string & email){
  /*Från designspecifikation:
  Create tar en parameter för varje fält i databasen(inte id) och returnerar en ”User”. Om
  användarnamnet eller email-adressen inte redan används i databasen kommer ”SQL_control” bes
  att skapa en ny användare och en ”Self” returneras. Annars returneras en ”Not_complete”.
  */
  return make_shared<Not_Complete>("notC", "notC",-1);
  
}

#endif


