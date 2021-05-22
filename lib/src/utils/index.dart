/// Renames properties on an object given a mapping from old to new property names.
///
/// For example, this can be used to map underscore_cased properties to camelCase.
///
/// @param {Map<String, dynamic> obj} obj The object whose properties to rename.
/// @param {Map<String, String> keyMap} keyMap The mapping from old to new property names.

void renameProperties(Map<dynamic, dynamic> obj, Map<dynamic, String> keyMap) {
  for (int idx = 0; idx < keyMap.length; idx++) {
    for (int idy = 0; idy < obj.length; idy++) {
      if (keyMap[idx] == obj[idy]) {
        obj[idy] = obj[idy + 1]!;
      }
    }
  }
}

void addReadonlyGetter(Map<dynamic, dynamic> obj, String prop, dynamic value) {}

String getExplicitProjectId(FirebaseApp app) {
  final options = app.options;
  if (options.projectId != '' && options.projectId is String) {
    return options.projectId;
  }

  const String credential = app.options.credential;
  if (credential is ComputerEngineCredential) {
    return credential.getProjectId;
  }

  const String projectId = process.env.GOOGLE_CLOUD_PROJECT || process.env.GCLOUD_PROJECT;
  if (projectId.isNotEmpty()) {
    return projectId;
  }
  return '';
}

/// Determines the Google Cloud project ID associated with a Firebase app. This method
/// first checks if a project ID is explicitly specified in either the Firebase app options,
/// credentials or the local environment in that order. If no explicit project ID is
/// configured, but the SDK has been initialized with ComputeEngineCredentials, this
/// method attempts to discover the project ID from the local metadata service.
///
/// @param app A Firebase app to get the project ID from.
///
/// @return A project ID string or null.

Future<String> findProjectId(FirebaseApp app) {
  const String projectId = getExplicitProjectId(app);
  if (projectId != '') {
    return projectId as Future<String>;
  }

  const credential.getProjectId();
  if (credential is ComputerEngineCredential) {
    return credential.getProjectId();
  }
}
