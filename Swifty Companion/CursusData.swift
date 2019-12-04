import Foundation

class CursusData : NSObject{
    var id:Int?
    var name:String
    
    init(event:[String:Any]){
        self.id         = event["id"] as? Int ?? 0
        self.name       = event["name"] as? String ?? ""
    }
    
    override var description: String {
        return "\(self.id ?? 1) of \(self.name)"
    }
}
