import Foundation

class ProjectData : NSObject{
    var id:Int?
    var name:String
    
    init(project:[String:Any]){
        self.id         = project["id"] as? Int ?? 0
        self.name       = project["name"] as? String ?? ""
    }
    
    override var description: String {
        return "\(self.id ?? 1) of \(self.name)"
    }
}
