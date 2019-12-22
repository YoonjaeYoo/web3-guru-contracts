pragma solidity ^0.5.11;
pragma experimental ABIEncoderV2;


import "./StringArrays.sol";
import "./Articles.sol";

library CMSs {
    using StringArrays for string[];

    struct CMS {
        mapping(string => Articles.Article) articleOfSlug;
        mapping(address => string[]) slugsOfAuthor;
        mapping(string => string[]) slugsOfTag;
        string[] allSlugs;
        string[] allTags;
    }

    function getArticles(
        CMS storage cms,
        uint256 fromIndex,
        uint256 count
    ) public view returns (Articles.Article[] memory) {
        return getArticles(cms.articleOfSlug, cms.allSlugs, fromIndex, count);
    }

    function getArticlesOfAuthor(
        CMS storage cms,
        address author,
        uint256 fromIndex,
        uint256 count
    ) public view returns (Articles.Article[] memory) {
        return getArticles(cms.articleOfSlug, cms.slugsOfAuthor[author], fromIndex, count);
    }

    function getArticlesOfTag(
        CMS storage cms,
        string memory tag,
        uint256 fromIndex,
        uint256 count
    ) public view returns (Articles.Article[] memory) {
        return getArticles(cms.articleOfSlug, cms.slugsOfTag[tag], fromIndex, count);
    }

    function createDraft(
        CMS storage cms,
        string memory slug,
        string memory coverImageUrl,
        string memory title,
        string memory excerpt,
        string memory content,
        bytes memory dummy,
        string[] memory tags
    ) public {
        require(cms.articleOfSlug[slug].author == address(0), "slug already used");

        cms.articleOfSlug[slug].slug = slug;
        cms.articleOfSlug[slug].author = msg.sender;
        cms.articleOfSlug[slug].revisions.push(Articles.Revision(coverImageUrl, title, excerpt, content, dummy, now));
        cms.articleOfSlug[slug].tags = tags;

        cms.slugsOfAuthor[msg.sender].insertFirst(slug);
        for (uint i = 0; i < tags.length; i++) {
            string memory tag = tags[i];
            bool tagExists = cms.slugsOfTag[tag].length > 0;
            cms.slugsOfTag[tag].insertFirst(slug);
            if (!tagExists) {
                cms.allTags.insertFirst(tag);
            }
        }
        cms.allSlugs.insertFirst(slug);
    }

    function update(
        CMS storage cms,
        string memory slug,
        string memory coverImageUrl,
        string memory title,
        string memory excerpt,
        string memory content,
        bytes memory dummy,
        string[] memory tags
    ) public {
        Articles.Article storage article = cms.articleOfSlug[slug];
        require(article.author == msg.sender, "only author can update");

        Articles.Revision storage latest = article.revisions[0];
        article.revisions.length += 1;
        for (uint i = article.revisions.length - 1; i >= 1; i--) {
            article.revisions[i] = article.revisions[i - 1];
        }
        article.revisions[0] = Articles.Revision(
            bytes(coverImageUrl).length == 0 ? latest.coverImageUrl : coverImageUrl,
            bytes(title).length == 0 ? latest.title : title,
            bytes(excerpt).length == 0 ? latest.excerpt : excerpt,
            bytes(content).length == 0 ? latest.content : content,
            bytes(dummy).length == 0 ? latest.dummy : dummy,
            now
        );
        for (uint i = 0; i < article.tags.length; i++) {
            string memory tag = article.tags[i];
            cms.slugsOfTag[tag].remove(slug);
            bool tagExists = cms.slugsOfTag[tag].length > 0;
            if (!tagExists) {
                cms.allTags.remove(tag);
            }
        }
        for (uint i = 0; i < tags.length; i++) {
            string memory tag = tags[i];
            bool tagExists = cms.slugsOfTag[tag].length > 0;
            cms.slugsOfTag[tag].insertFirst(slug);
            if (!tagExists) {
                cms.allTags.insertFirst(tag);
            }
        }
        article.tags = tags;
    }

    function getArticles(
        mapping(string => Articles.Article) storage articleOfSlug,
        string[] memory slugs,
        uint256 fromIndex,
        uint256 count
    ) internal view returns (Articles.Article[] memory) {
        if (slugs.length - fromIndex < count) {
            count = slugs.length - fromIndex;
        }
        Articles.Article[] memory articles = new Articles.Article[](count);
        for (uint i = 0; i < count; i++) {
            articles[i] = articleOfSlug[slugs[fromIndex + i]];
        }
        return articles;
    }
}
