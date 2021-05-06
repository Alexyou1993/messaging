


void renameProperties(Map<dynamic, String> obj, Map<String, String> keyMap) {
  for(int idx = 0; idx< keyMap.length; idx++){
    for(int idy =0; idy < obj.length; idy++){
      if(keyMap[idx] == obj[idy]){
        obj[idy] = obj[idy+1]!;
      }
    }
  }
}

void addReadonlyGetter(Map<dynamic, dynamic> obj, String prop, dynamic value) {}

String getExplicitProjectId(_app.App app) {
  final options = app.options;
  if(options.projectId != '' && options.projectId is String){
    return options.projectId;
  }

  const String credential = app.options.credential;
  if(credential  is ComputerEngineCredential) {
    return credential.getProjectId;
  }

  const String projectId = process.env.GOOGLE_CLOUD_PROJECT || process.env.GCLOUD_PROJECT;
  if(projectId.isNotEmpty()) {
    return projectId;
  }
  return '';
}
