#include<iostream>
#include<vector>
#include<memory>
#include "user.h"

using namespace std;

int main(){
  Self self("BigPimpin'", "Tobias", "Sävenhed", 5, "tobias@lundgrendesign.se");
  vector<shared_ptr<User> > nd;
  for(int i{0}; i< 10 ; ++i){
    shared_ptr<User> baba = make_shared<Contact>("test", "maja", "baja", i, i);
    nd.push_back(baba);
  }

  self.insert_end(nd);
  self.refresh();
  
  cout << self.name() << " "<< self.surname() << " "<< self.email() << " " <<
  self.total() << endl;

  self.push_back(make_shared<Contact>("fafa", "petrus", "elis", 100, 0));
  self.change_debt("fafa", 1000);

  self.refresh();

  cout << self.name() << " "<< self.surname() << " "<< self.email() << " " <<
  self.total() << endl;

  return 0;
}


