import 'package:flutter/material.dart';
import 'package:minio/models.dart';
import 'package:play_nuvem/models/nuvem_model.dart';
import 'package:play_nuvem/models/reproduction_items.dart';
import 'package:play_nuvem/repositories/midia_repository.dart';
import 'package:play_nuvem/repositories/midia_repository_imp.dart';
import 'package:play_nuvem/repositories/nuvem_repository.dart';
import 'package:play_nuvem/repositories/nuvem_repository_imp.dart';

class NuvemController with ChangeNotifier {
  final NuvemRepository _nuvemRepository = NuvemRepositoryImp();
  final MidiaRepository _midiaRepository = MidiaRepositoryImp();
  List<ReproductionItems> _listReproductionItems = [];
  String _url = '';
  String _imdbId = '';
  final List<NuvemModel> _listNuvem = [
    NuvemModel(
        tipo: 'Storj',
        name: 'Nuvem1',
        credenciais: Credentials(
            endPoint: 'gateway.storjshare.io',
            accessKey: 'jveeoqxw266lkvvm3n7cweqheana',
            secretKey: 'j2pgl3fbdovzemklukp2baxcr3auc54rmgq36gpavd2ybb3nv3h4u',
            ),
        pathBucketMovies: 'demo-bucket',
        pathBucketTvShows: 'demo-bucket',
        id: '12345',
        totalcountitems: '0'),
    //Random(10).nextDouble().toString()
  ];
  List<String> listateste = [
    'https://edisciplinas.usp.br/pluginfile.php/5196097/mod_resource/content/1/Teste.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
  ];

  String get url {
    return _url;
  }

  String get imdbId {
    return _imdbId;
  }
  List<ReproductionItems> get listReproductionItems {
    return _listReproductionItems;
  }
  List<NuvemModel> get listNuvem {
    return _listNuvem;
  }

  void updateUrl({int? index = 0}) {
      _url = listReproductionItems[index!].url; //listateste[index!];
      notifyListeners();
    }

  Future<void> loadMovies(String imdbId) async {
    try {
      _listReproductionItems.clear();
      await fetchListReproduction(imdbId, 'movie');
      
      notifyListeners();
    } catch (error, StackTrace) {
      print("Exception occured: $error by $StackTrace");
    }
  }

  Future<void> loadTvShows(String tvId) async {
    try {
      _listReproductionItems.clear();
      _imdbId = await _midiaRepository.getImdb(tvId, 'tv');
      await fetchListReproduction('${_imdbId}_S01_E01', 'tv');
      
      notifyListeners();
    } catch (error, StackTrace) {
      print("Exception occured: $error by $StackTrace");
    }
  }

  Future<void> updateTvShows(String episode) async {
    try {
      _listReproductionItems.clear();
      await fetchListReproduction('$_imdbId$episode', 'tv');
      
      notifyListeners();
    } catch (error, StackTrace) {
      print("Exception occured: $error by $StackTrace");
    }
  }

  Future<void> fetchListReproduction(String titleSearch, String midiaType) async {
    for (var list in listNuvem) {
      ListObjectsResult _lista = await _nuvemRepository.getListReproduction(
        endPoint: list.credenciais.endPoint,
        accessKey: list.credenciais.accessKey,
        secretKey: list.credenciais.secretKey,
        titleSearch: titleSearch,
        PathBucket: midiaType == 'movie' ? list.pathBucketMovies! : list.pathBucketTvShows!,
      );

      if(_lista.objects.length > 1) {
        for(var i = 0; i <= _lista.objects.length; i++) {
        List<String> separated = _lista.objects[i].key!.split('_'); 
        
        // tt0944947_nomedoarquivo_2011_A+EN+PT_R720p.mp4
        String url = await _nuvemRepository.getUrl(
          endPoint: list.credenciais.endPoint, 
          accessKey: list.credenciais.accessKey, 
          secretKey: list.credenciais.secretKey, 
          title: _lista.objects[i].key!, 
          PathBucket: midiaType == 'movie' ? list.pathBucketMovies! : list.pathBucketTvShows!,
          ); 
          
        _listReproductionItems.add(
          ReproductionItems(
            tipoNuvem: list.tipo,
            nameNuvem: list.name,
            title: _lista.objects[i].key!,
            resolution: separated[4].substring(1, 6),
            url: url,
          ),
        );
        }
      } else if(_lista.objects.length == 1) {
         List<String> separated = _lista.objects[0].key!.split('_'); 
        // tt0944947_nomedoarquivo_2011_A+EN+PT_R720p.mp4
        String url = await _nuvemRepository.getUrl(
          endPoint: list.credenciais.endPoint, 
          accessKey: list.credenciais.accessKey, 
          secretKey: list.credenciais.secretKey, 
          title: _lista.objects[0].key!, 
          PathBucket: midiaType == 'movie' ? list.pathBucketMovies! : list.pathBucketTvShows!,
          );  
            
        _listReproductionItems.add(
          ReproductionItems(
            tipoNuvem: list.tipo,
            nameNuvem: list.name,
            title: _lista.objects[0].key!,
            resolution: separated[4].substring(1, 6),
            url: url,
          ),
        );
      } else {
        
      }
    }
  }
  
}
